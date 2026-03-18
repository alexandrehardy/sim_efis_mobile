import 'dart:async';
import 'dart:io';

import 'package:sim_efis/logs.dart';
import 'package:sim_efis/settings.dart';

bool isWifi(NetworkInterface interface) {
  if (interface.name.startsWith('en')) return true;
  if (interface.name.startsWith('wlan')) return true;
  return false;
}

bool isMobile(NetworkInterface interface) {
  if (interface.name.startsWith('pdp')) return true;
  if (interface.name.startsWith('radio')) return true;
  return false;
}

Future<List<NetworkInterface>> getOrderedNetworks() async {
  List<NetworkInterface> interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);

  List<NetworkInterface> enInterfaces =
      interfaces.where((interface) => isWifi(interface)).toList();
  List<NetworkInterface> otherInterfaces =
      interfaces.where((interface) => !isWifi(interface)).toList();

  List<NetworkInterface> orderedInterfaces = List.from(enInterfaces);
  orderedInterfaces.addAll(otherInterfaces);

  return orderedInterfaces
      .where((interface) => interface.addresses.isNotEmpty)
      .toList();
}

Future<NetworkInterface?> getLocalNetwork() async {
  List<NetworkInterface> interfaces = await getOrderedNetworks();

  for (NetworkInterface interface in interfaces) {
    if (interface.addresses.isNotEmpty) {
      return interface;
    }
  }
  return null;
}

Future<InternetAddress?> getLocalNetworkAddress() async {
  NetworkInterface? interface = await getLocalNetwork();
  if (interface == null) {
    return null;
  }
  return interface.addresses.first;
}

Future<String> getSubnetString() async {
  InternetAddress? address = await getLocalNetworkAddress();
  if (address == null) return '192.168.1.0';
  return '${address.rawAddress.take(3).join('.')}.0';
}

Future<String?> getPreferredListenAddress() async {
  InternetAddress? address = await getLocalNetworkAddress();
  if (address == null) return null;
  return address.address;
}

bool networkRequested = false;
Future<void> ensureNetworkPermissionTriggered() async {
  const int discardPort = 9;
  if (networkRequested) return;
  networkRequested = true;

  if ((Platform.isIOS) || (Platform.isMacOS)) {
    Logger.log('Network: Triggering network request');
    RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );

    List<NetworkInterface> interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);

    for (NetworkInterface interface in interfaces) {
      Logger.log('Network: Found interface ${interface.name}');
      if (interface.addresses.isNotEmpty) {
        String subnet = interface.addresses[0].rawAddress.take(3).join('.');
        Logger.log('Network: Sending discard packet to $subnet.255');
        socket.broadcastEnabled = true;
        socket.send(
          'discard'.codeUnits,
          InternetAddress('$subnet.255', type: InternetAddressType.IPv4),
          discardPort,
        );
      }
    }
    socket.close();
  }
}

class SocketWriteEvent {
  final List<int> buffer;
  final InternetAddress address;
  final int port;

  const SocketWriteEvent({
    required this.buffer,
    required this.address,
    required this.port,
  });
}

class BufferedDatagramSocket {
  final RawDatagramSocket socket;
  bool closed = false;
  final StreamController<SocketWriteEvent> controller = StreamController();

  BufferedDatagramSocket({required this.socket}) {
    processJobs(controller.stream);
  }

  InternetAddress get address => socket.address;
  int get port => socket.port;
  Datagram? receive() => socket.receive();

  void close() {
    if (closed) {
      return;
    }
    closed = true;
    socket.close();
    controller.close();
  }

  void send(List<int> buffer, InternetAddress address, int port) {
    if (closed) {
      return;
    }
    controller.add(SocketWriteEvent(
      buffer: buffer,
      address: address,
      port: port,
    ));
  }

  Future<void> processJobs(Stream<SocketWriteEvent> stream) async {
    await for (final SocketWriteEvent job in stream) {
      try {
        int sent = 0;
        int tries = 5;
        while ((sent == 0) && (tries > 0)) {
          tries--;
          sent = socket.send(job.buffer, job.address, job.port);
          if (sent == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
      } catch (e, s) {
        Logger.logError('Failed to send data: $e', s);
      }
    }
  }
}

class NetworkPorts {
  static Map<Simulator, int> networkPorts = {};
  static Map<Simulator, int> defaultPorts = {};

  static void setupPreferredPorts() {
    networkPorts[Simulator.None] = 0;
    networkPorts[Simulator.Random] = 0;
    networkPorts[Simulator.IL2_1946] = 51946;
    networkPorts[Simulator.XPlane] = 49010;
    networkPorts[Simulator.FlightGear] = 51000;
    networkPorts[Simulator.DCS] = 52000;
    networkPorts[Simulator.MSFS2020] = 50000;
  }

  static void setupDefaultPorts() {
    defaultPorts[Simulator.None] = 0;
    defaultPorts[Simulator.Random] = 0;
    defaultPorts[Simulator.IL2_1946] = 11946;
    defaultPorts[Simulator.XPlane] = 49000;
    defaultPorts[Simulator.FlightGear] = 0;
    defaultPorts[Simulator.DCS] = 45000;
    defaultPorts[Simulator.MSFS2020] = 52020;
  }

  static Future<BufferedDatagramSocket> _createSocket(
      Simulator simulator) async {
    int listenPort = networkPorts[simulator]!;
    RawDatagramSocket socket;

    if (Settings.listenOn == null) {
      socket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, listenPort);
    } else {
      socket = await RawDatagramSocket.bind(
        InternetAddress(
          Settings.listenOn!,
          type: InternetAddressType.IPv4,
        ),
        listenPort,
        reusePort: true,
      );
    }

    if (listenPort == 0) {
      listenPort = socket.port;
      // We didn't have a port specified, get the assigned port
      networkPorts[simulator] = listenPort;
    }

    return BufferedDatagramSocket(socket: socket);
  }

  static Future<BufferedDatagramSocket> createSocket(
      Simulator simulator) async {
    try {
      return await _createSocket(simulator);
    } on SocketException {
      // Reset the port, and take whatever we get.
      networkPorts[simulator] = 0;
      return await _createSocket(simulator);
    }
  }
}
