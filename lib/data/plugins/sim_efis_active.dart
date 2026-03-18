import 'dart:io';

import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/sim_efis_passive.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/settings.dart';

class SimEfisActiveUDP extends SimEfisPassiveUDP {
  @override
  String get name => 'SimEfisActiveUDP';
  bool scanning = true;
  DateTime nextScanTime = DateTime(0);
  String scanHost = '192.168.1';
  int connectPort = 45000; // The port on which to send data

  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    await super.init(connectTo: connectTo, port: port, simulator: simulator);
    connectPort = port;
    scanHost = connectTo;
  }

  void scanForSimEfis() {
    int i;
    DateTime now = DateTime.now();
    if (now.isAfter(nextScanTime)) {
      //if (Platform.isIOS) {
      // Recreate the socket for each scan on ios.
      // It begins failing if we get no response.
      //  await recreateSocket();
      //}
      List<String> parts = scanHost.split('.');
      if ((parts.length == 4) && (parts[3] == '0')) {
        String subnet = parts.take(3).join('.');
        Logger.log('SimEfisProtocol: Polling subnet $subnet.0/24:$connectPort');
        for (i = 1; i < 254; i++) {
          // Ask for version and time and wait for response
          socket!.send(
            'PING'.codeUnits,
            InternetAddress('$subnet.$i', type: InternetAddressType.IPv4),
            connectPort,
          );
        }
      } else {
        // Ask for time and wait for response
        Logger.log(
            'SimEfisProtocol: Polling host $scanHost:      $connectPort');
        socket!.send(
          'PING'.codeUnits,
          InternetAddress(scanHost, type: InternetAddressType.IPv4),
          connectPort,
        );
      }
      // Allow 2 seconds for response
      nextScanTime = now.add(const Duration(seconds: 2));
    } else {
      Datagram? response;
      response = socket!.receive();
      while (response != null) {
        // TODO: Refuse packets from anything but this IP.
        host = response.address;
        scanning = false;
        Logger.log('SimEfisProtocol: Got response from ${host!.address}');
        response = socket!.receive();
      }
    }
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    if (socket == null) return current;
    if (scanning) {
      DateTime now = DateTime.now();
      try {
        scanForSimEfis();
      } on OSError catch (e) {
        if (e.errorCode == 9) {
          // Bad file descriptor
          await recreateSocket();
        } else {
          rethrow;
        }
      }
      lastPoll = now;
      return current;
    } else {
      return await super.poll(current);
    }
  }

  @override
  bool get active => scanning == false;

  @override
  bool get reconnectAfterSleep => true;
}
