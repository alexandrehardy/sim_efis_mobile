import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/data/utils.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/settings.dart';

enum IsetType { iset, iset4 }

class XplaneIsetPacket {
  final int index;
  final String strIpadThem;
  final String strPortThem;
  final bool useIp;
  final IsetType type;
  const XplaneIsetPacket({
    int? index,
    required this.strIpadThem,
    required this.strPortThem,
    required this.useIp,
    required this.type,
  }) : index = (index == null) ? ((type == IsetType.iset) ? 60 : 64) : index;

  Uint8List encode() {
    int i;
    String header = (type == IsetType.iset4) ? 'ISE4' : 'ISET';
    List<int> headerInt = header.codeUnits;
    int portSize = 8;
    ByteData data = ByteData(5 + 4 + 16 + 8 + 4);
    data.setUint8(0, headerInt[0]);
    data.setUint8(1, headerInt[1]);
    data.setUint8(2, headerInt[2]);
    data.setUint8(3, headerInt[3]);
    data.setUint8(4, 0);
    data.setInt32(5, index, Endian.little);
    List<int> ip = strIpadThem.codeUnits.take(15).toList();
    while (ip.length < 16) {
      ip.add(0);
    }
    for (i = 0; i < ip.length; i++) {
      data.setUint8(5 + 4 + i, ip[i]);
    }

    List<int> port = strPortThem.codeUnits.take(portSize - 1).toList();
    while (port.length < portSize) {
      port.add(0);
    }
    for (i = 0; i < port.length; i++) {
      data.setUint8(5 + 4 + 16 + i, port[i]);
    }
    data.setInt32(5 + 4 + 16 + portSize, useIp ? 1 : 0, Endian.little);
    Uint8List output = data.buffer.asUint8List();
    while ((output.length - 5) % 4 != 0) {
      output.add(0);
    }
    return output;
  }
}

class XPlaneSelectDataItemPacket {
  final bool unSelect;
  final List<int> items;
  const XPlaneSelectDataItemPacket({
    required this.items,
    required this.unSelect,
  });

  Uint8List encode() {
    int i;
    ByteData data = ByteData(5 + items.length * 4);
    String header = unSelect ? 'USEL' : 'DSEL';
    List<int> headerInt = header.codeUnits;
    data.setUint8(0, headerInt[0]);
    data.setUint8(1, headerInt[1]);
    data.setUint8(2, headerInt[2]);
    data.setUint8(3, headerInt[3]);
    data.setUint8(4, 0);
    for (i = 0; i < items.length; i++) {
      data.setUint32(5 + i * 4, items[i], Endian.little);
    }
    return data.buffer.asUint8List();
  }
}

class XPlaneDataPacket {
  final int index;
  final List<double> data;
  const XPlaneDataPacket({
    required this.index,
    required this.data,
  });
  static XPlaneDataPacket decode(Uint8List packet) {
    int i;
    ByteData data = ByteData.view(packet.buffer);
    int index = data.getUint32(0, Endian.little);
    List<double> results = [];
    for (i = 0; i < 8; i++) {
      results.add(data.getFloat32(4 + i * 4, Endian.little));
    }
    return XPlaneDataPacket(index: index, data: results);
  }

  static int get size => 4 + 8 * 4;
}

class XplaneDatarefRequestPacket {
  final int frequency;
  final int tag; // How we want it to be tagged
  final String dataref;

  const XplaneDatarefRequestPacket({
    required this.frequency,
    required this.tag,
    required this.dataref,
  });

  Uint8List encode() {
    int i;
    ByteData data = ByteData(5 + 8 + 400);
    for (i = 0; i < data.lengthInBytes; i++) {
      data.setUint8(i, 0);
    }
    String header = 'RREF';
    List<int> headerInt = header.codeUnits;
    data.setUint8(0, headerInt[0]);
    data.setUint8(1, headerInt[1]);
    data.setUint8(2, headerInt[2]);
    data.setUint8(3, headerInt[3]);
    data.setUint8(4, 0);
    data.setUint32(5, frequency, Endian.little);
    data.setUint32(5 + 4, tag, Endian.little);
    List<int> datarefInt = dataref.codeUnits;
    for (i = 0; i < dataref.length; i++) {
      data.setUint8(5 + 8 + i, datarefInt[i]);
    }
    return data.buffer.asUint8List();
  }
}

class XplaneDatarefResponseItem {
  final int tag;
  final double value;

  const XplaneDatarefResponseItem({
    required this.tag,
    required this.value,
  });
}

class XPlaneDatarefResponsePacket {
  final List<XplaneDatarefResponseItem> datarefs;

  const XPlaneDatarefResponsePacket({
    required this.datarefs,
  });

  static XPlaneDatarefResponsePacket decode(Uint8List packet) {
    int i = 0;
    List<XplaneDatarefResponseItem> datarefs = [];
    ByteData data = ByteData.view(packet.buffer);
    for (i = 0; i + 8 < data.lengthInBytes; i += 8) {
      int tag = data.getUint32(i, Endian.little);
      double value = data.getFloat32(i + 4, Endian.little);
      datarefs.add(XplaneDatarefResponseItem(tag: tag, value: value));
    }
    return XPlaneDatarefResponsePacket(datarefs: datarefs);
  }
}

class XplaneSetDatarefPacket {
  final double value;
  final String dataref;

  const XplaneSetDatarefPacket({
    required this.value,
    required this.dataref,
  });

  Uint8List encode() {
    int i;
    ByteData data = ByteData(5 + 4 + 500);
    for (i = 0; i < data.lengthInBytes; i++) {
      data.setUint8(i, 0);
    }
    String header = 'DREF';
    List<int> headerInt = header.codeUnits;
    data.setUint8(0, headerInt[0]);
    data.setUint8(1, headerInt[1]);
    data.setUint8(2, headerInt[2]);
    data.setUint8(3, headerInt[3]);
    data.setUint8(4, 0);
    data.setFloat32(5, value, Endian.little);
    List<int> datarefInt = dataref.codeUnits;
    for (i = 0; i < dataref.length; i++) {
      data.setUint8(5 + 4 + i, datarefInt[i]);
    }
    return data.buffer.asUint8List();
  }
}

class XPlaneSourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'X-Plane';

  static const int dataFramerate = 0;
  static const int dataTimes = 1;
  static const int dataSim = 2;
  static const int dataSpeeds = 3;
  static const int dataMachVsi = 4;
  static const int dataWeather = 5;
  static const int dataAtmo = 6;
  static const int dataPressure = 7;
  static const int dataJoystick = 8;
  static const int dataOtherCtl = 9;
  static const int dataAStab = 10;
  static const int dataFlightCtl = 11;
  static const int dataSweep = 12;
  static const int dataTrim = 13;
  static const int dataGearBrk = 14;
  static const int dataAngular = 15;
  static const int dataAngMoment = 16;
  static const int dataAngVel = 17;
  static const int dataPitchRoll = 18;
  static const int dataAoa = 19;
  static const int dataLatLongAlt = 20;
  static const int dataLocation = 21;
  static const int dataAllLat = 22;
  static const int dataAllLon = 23;
  static const int dataAllAlt = 24;
  static const int dataThrottleSet = 25;
  static const int dataThrottle = 26;
  static const int dataFeather = 27;
  static const int dataProp = 28;
  static const int dataMixture = 29;
  static const int dataCarbHeat = 30;
  static const int dataCowlFlap = 31;
  static const int dataIgnition = 32;
  static const int dataStarter = 33;
  static const int dataPower = 34;
  static const int dataThrust = 35;
  static const int dataTorque = 36;
  static const int dataRpm = 37;
  static const int dataPropRpm = 38;
  static const int dataPropPitch = 39;
  static const int dataPropWash = 40;
  static const int dataManifoldPressure = 43;
  static const int dataFuelFlow = 45;
  static const int dataExhaustGasTemperature = 47;
  static const int dataCylinderHeadTemperature = 48;
  static const int dataOilPressure = 49;
  static const int dataOilTemperature = 50;
  static const int dataFuelWeights = 62;
  static const int dataGear = 67;

  static const int datarefVso = 1;
  static const int datarefVs = 2;
  static const int datarefVfe = 3;
  static const int datarefVno = 4;
  static const int datarefVne = 5;
  static const int datarefNumEngines = 6;
  static const int datarefMaxEgt = 7;
  static const int datarefMaxCht = 8;
  static const int datarefMaxOilp = 9;
  static const int datarefMaxOilt = 10;
  static const int datarefGreenLoMp = 11;
  static const int datarefGreenHiMp = 12;
  static const int datarefYellowLoMp = 13;
  static const int datarefYellowHiMp = 14;
  static const int datarefRedLoMp = 15;
  static const int datarefRedHiMp = 16;
  static const int datarefGreenLoEgt = 17;
  static const int datarefGreenHiEgt = 18;
  static const int datarefYellowLoEgt = 19;
  static const int datarefYellowLoMegt = 20;
  static const int datarefRedLoEgt = 21;
  static const int datarefRedHiEgt = 22;
  static const int datarefGreenLoCht = 23;
  static const int datarefGreenHiCht = 24;
  static const int datarefYellowLoCht = 25;
  static const int datarefYellowHiCht = 26;
  static const int datarefRedLoCht = 27;
  static const int datarefRedHiCht = 28;
  static const int datarefGreenLoOilp = 29;
  static const int datarefGreenHiOilp = 30;
  static const int datarefYellowLoOilp = 31;
  static const int datarefYellowHiOilp = 32;
  static const int datarefRedLoOilp = 33;
  static const int datarefRedHiOilp = 34;
  static const int datarefGreenLoOilt = 35;
  static const int datarefGreenHiOilt = 36;
  static const int datarefYellowLoOilt = 37;
  static const int datarefYellowHiOilt = 38;
  static const int datarefRedLoOilt = 39;
  static const int datarefRedHiOilt = 40;

  static const int stringDatarefBase = 1000;
  static const int datarefTailnum = 1000;
  static const int datarefIcao = 2000;

  static const List<int> dataInterest = [
    dataTimes,
    dataSpeeds,
    dataMachVsi,
    dataTrim,
    dataAngVel,
    dataAngMoment,
    dataPitchRoll,
    dataAoa,
    dataLatLongAlt,
    dataRpm,
    dataOilPressure,
    dataOilTemperature,
    dataFuelWeights,
    dataGear,
    dataManifoldPressure,
    dataFuelFlow,
    dataExhaustGasTemperature,
    dataCylinderHeadTemperature,
  ];

  BufferedDatagramSocket? socket;
  InternetAddress? host;
  int connectPort = 49000; // The port on which to send data
  bool scanning = true;
  DateTime nextScanTime = DateTime(0);
  DateTime lastPoll = DateTime(0);
  // laggy instruments
  double slip = 0.0;
  double variometer = 0.0;
  // interpolate position
  double flaps = 0.0;
  // Internal time keeping
  double clock = 0.0;
  String scanHost = '192.168.1';
  int version = 9; // X-plane version, 9 or 11.
  List<int> tailNumber = List.filled(41, 0);
  List<int> aircraftType = List.filled(41, 0);
  Simulator simulator = Simulator.XPlane;

  InstrumentState state = InstrumentState(lastResponse: DateTime(0));

  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    int i;
    state.engines = [];
    for (i = 0; i < maxEngines; i++) {
      state.engines.add(const EngineState());
    }
    this.simulator = simulator;
    await recreateSocket();
    lastPoll = DateTime.now();
    connectPort = port;
    scanHost = connectTo;
    await ensureNetworkPermissionTriggered();
  }

  Future<void> recreateSocket() async {
    if (socket != null) {
      socket!.close();
    }
    socket = await NetworkPorts.createSocket(simulator);
    String listenAddress = '${socket!.address.address}:${socket!.port}';
    Logger.log('Listening on $listenAddress');
    UiStateController.setListenOn(listenAddress);
  }

  @override
  Future<void> close() async {
    if (socket == null) {
      return;
    }
    if (host != null) {
      socket!.send(
        XplaneIsetPacket(
          strIpadThem: socket!.address.address,
          strPortThem: '${socket!.port}',
          useIp: false,
          type: IsetType.iset,
        ).encode(),
        host!,
        connectPort,
      );
      socket!.send(
        XplaneIsetPacket(
          strIpadThem: socket!.address.address,
          strPortThem: '${socket!.port}',
          useIp: false,
          type: IsetType.iset4,
        ).encode(),
        host!,
        connectPort,
      );
    }

    socket?.close();
    socket = null;
  }

  void sendMessage(String message) {
    socket!.send(message.codeUnits, host!, connectPort);
  }

  void sendSetupPackets(InternetAddress address) {
    socket!.send(
      XplaneIsetPacket(
        strIpadThem: socket!.address.address,
        strPortThem: '${socket!.port}',
        useIp: true,
        type: IsetType.iset,
      ).encode(),
      address,
      connectPort,
    );
    socket!.send(
      XplaneIsetPacket(
        strIpadThem: socket!.address.address,
        strPortThem: '${socket!.port}',
        useIp: true,
        type: IsetType.iset4,
      ).encode(),
      address,
      connectPort,
    );

    List<int> unselect = [];
    for (int i = 0; i <= 127; i++) {
      if (!dataInterest.contains(i)) {
        unselect.add(i);
      }
    }

    socket!.send(
      XPlaneSelectDataItemPacket(
        items: unselect,
        unSelect: true,
      ).encode(),
      address,
      connectPort,
    );

    socket!.send(
      const XPlaneSelectDataItemPacket(
        items: dataInterest,
        unSelect: false,
      ).encode(),
      address,
      connectPort,
    );
    sendDatarefRequests(address);
  }

  void sendGetXplaneDataref(InternetAddress address, int tag, String dataref) {
    XplaneDatarefRequestPacket datarefRequest = XplaneDatarefRequestPacket(
      frequency: 1,
      tag: tag,
      dataref: dataref,
    );
    socket!.send(datarefRequest.encode(), address, connectPort);
  }

  void sendGetStringXplaneDataref(
      InternetAddress address, int tag, String dataref, int len) {
    int i;
    for (i = 0; i < len; i++) {
      XplaneDatarefRequestPacket datarefRequest = XplaneDatarefRequestPacket(
        frequency: 1,
        tag: tag + i,
        dataref: '$dataref[$i]',
      );
      socket!.send(datarefRequest.encode(), address, connectPort);
    }
  }

  void sendSetXplaneDataref(
      InternetAddress address, String dataref, double value) {
    XplaneSetDatarefPacket setDatarefPacket = XplaneSetDatarefPacket(
      value: value,
      dataref: dataref,
    );
    socket!.send(setDatarefPacket.encode(), address, connectPort);
  }

  void sendDatarefRequests(InternetAddress address) {
    // https://developer.x-plane.com/datarefs/
    sendGetStringXplaneDataref(
        address, datarefTailnum, 'sim/aircraft/view/acf_tailnum', 40);
    sendGetStringXplaneDataref(
        address, datarefIcao, 'sim/aircraft/view/acf_ICAO', 40);
    sendGetXplaneDataref(address, datarefVso, 'sim/aircraft/view/acf_Vso');
    sendGetXplaneDataref(address, datarefVs, 'sim/aircraft/view/acf_Vs');
    sendGetXplaneDataref(address, datarefVfe, 'sim/aircraft/view/acf_Vfe');
    sendGetXplaneDataref(address, datarefVno, 'sim/aircraft/view/acf_Vno');
    sendGetXplaneDataref(address, datarefVne, 'sim/aircraft/view/acf_Vne');
    sendGetXplaneDataref(
        address, datarefMaxEgt, 'sim/aircraft/engine/acf_max_EGT');
    sendGetXplaneDataref(
        address, datarefMaxCht, 'sim/aircraft/engine/acf_max_CHT');
    sendGetXplaneDataref(
        address, datarefMaxOilp, 'sim/aircraft/engine/acf_max_OILP');
    sendGetXplaneDataref(
        address, datarefMaxOilt, 'sim/aircraft/engine/acf_max_OILT');
    sendGetXplaneDataref(
        address, datarefGreenLoMp, 'sim/aircraft/limits/green_lo_MP');
    sendGetXplaneDataref(
        address, datarefGreenHiMp, 'sim/aircraft/limits/green_hi_MP');
    sendGetXplaneDataref(
        address, datarefYellowLoMp, 'sim/aircraft/limits/yellow_lo_MP');
    sendGetXplaneDataref(
        address, datarefYellowHiMp, 'sim/aircraft/limits/yellow_hi_MP');
    sendGetXplaneDataref(
        address, datarefRedLoMp, 'sim/aircraft/limits/red_lo_MP');
    sendGetXplaneDataref(
        address, datarefRedHiMp, 'sim/aircraft/limits/red_hi_MP');
    sendGetXplaneDataref(
        address, datarefGreenLoEgt, 'sim/aircraft/limits/green_lo_EGT');
    sendGetXplaneDataref(
        address, datarefGreenHiEgt, 'sim/aircraft/limits/green_hi_EGT');
    sendGetXplaneDataref(
        address, datarefYellowLoEgt, 'sim/aircraft/limits/yellow_lo_EGT');
    sendGetXplaneDataref(
        address, datarefYellowLoMegt, 'sim/aircraft/limits/yellow_hi_EGT');
    sendGetXplaneDataref(
        address, datarefRedLoEgt, 'sim/aircraft/limits/red_lo_EGT');
    sendGetXplaneDataref(
        address, datarefRedHiEgt, 'sim/aircraft/limits/red_hi_EGT');
    sendGetXplaneDataref(
        address, datarefGreenLoCht, 'sim/aircraft/limits/green_lo_CHT');
    sendGetXplaneDataref(
        address, datarefGreenHiCht, 'sim/aircraft/limits/green_hi_CHT');
    sendGetXplaneDataref(
        address, datarefYellowLoCht, 'sim/aircraft/limits/yellow_lo_CHT');
    sendGetXplaneDataref(
        address, datarefYellowHiCht, 'sim/aircraft/limits/yellow_hi_CHT');
    sendGetXplaneDataref(
        address, datarefRedLoCht, 'sim/aircraft/limits/red_lo_CHT');
    sendGetXplaneDataref(
        address, datarefRedHiCht, 'sim/aircraft/limits/red_hi_CHT');
    sendGetXplaneDataref(
        address, datarefGreenLoOilp, 'sim/aircraft/limits/green_lo_oilP');
    sendGetXplaneDataref(
        address, datarefGreenHiOilp, 'sim/aircraft/limits/green_hi_oilP');
    sendGetXplaneDataref(
        address, datarefYellowLoOilp, 'sim/aircraft/limits/yellow_lo_oilP');
    sendGetXplaneDataref(
        address, datarefYellowHiOilp, 'sim/aircraft/limits/yellow_hi_oilP');
    sendGetXplaneDataref(
        address, datarefRedLoOilp, 'sim/aircraft/limits/red_lo_oilP');
    sendGetXplaneDataref(
        address, datarefRedHiOilp, 'sim/aircraft/limits/red_hi_oilP');
    sendGetXplaneDataref(
        address, datarefGreenLoOilt, 'sim/aircraft/limits/green_lo_oilT');
    sendGetXplaneDataref(
        address, datarefGreenHiOilt, 'sim/aircraft/limits/green_hi_oilT');
    sendGetXplaneDataref(
        address, datarefYellowLoOilt, 'sim/aircraft/limits/yellow_lo_oilT');
    sendGetXplaneDataref(
        address, datarefYellowHiOilt, 'sim/aircraft/limits/yellow_hi_oilT');
    sendGetXplaneDataref(
        address, datarefRedLoOilt, 'sim/aircraft/limits/red_lo_oilT');
    sendGetXplaneDataref(
        address, datarefRedHiOilt, 'sim/aircraft/limits/red_hi_oilT');
  }

  Future<void> scanForXPlane() async {
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
        Logger.log('X-Plane: Polling subnet $subnet.0/24');
        for (i = 1; i < 254; i++) {
          sendSetupPackets(InternetAddress(
            '$subnet.$i',
            type: InternetAddressType.IPv4,
          ));
        }
      } else {
        // Ask for time and wait for response
        Logger.log('X-Plane: Polling host $scanHost');
        sendSetupPackets(
          InternetAddress(
            scanHost,
            type: InternetAddressType.IPv4,
          ),
        );
      }
      // Allow 5 seconds for response
      nextScanTime = now.add(const Duration(seconds: 5));
    } else {
      Datagram? response;
      response = socket!.receive();
      while (response != null) {
        // TODO: Refuse packets from anything but this IP.
        host = response.address;
        if (cStringToDartString(response.data.take(4)) == 'DATA') {
          scanning = false;
          Logger.log('X-Plane: Got response from ${host!.address}');
        }
        response = socket!.receive();
      }
    }
  }

  void processDatarefs(XPlaneDatarefResponsePacket response) {
    bool receivedAircraftType = false;
    bool receivedTailNumber = false;
    for (XplaneDatarefResponseItem item in response.datarefs) {
      if ((item.tag >= datarefIcao) && (item.tag < datarefIcao + 40)) {
        aircraftType[item.tag - datarefIcao] = item.value.toInt();
        receivedAircraftType = true;
      }
      if ((item.tag >= datarefTailnum) && (item.tag < datarefTailnum + 40)) {
        tailNumber[item.tag - datarefTailnum] = item.value.toInt();
        receivedTailNumber = true;
      }
      switch (item.tag) {
        case datarefVso:
          state.limits = state.limits.copyWith(vso: item.value);
          break;
        case datarefVs:
          state.limits = state.limits.copyWith(vs: item.value);
          break;
        case datarefVfe:
          state.limits = state.limits.copyWith(vfe: item.value);
          break;
        case datarefVno:
          state.limits = state.limits.copyWith(vno: item.value);
          break;
        case datarefVne:
          state.limits = state.limits.copyWith(vne: item.value);
          break;
        case datarefNumEngines:
          //state->number_of_engines = (int)response.dataref;
          break;
        case datarefMaxEgt:
        case datarefMaxCht:
        case datarefMaxOilp:
        case datarefMaxOilt:
        case datarefGreenLoMp:
        case datarefGreenHiMp:
        case datarefYellowLoMp:
        case datarefYellowHiMp:
        case datarefRedLoMp:
        case datarefRedHiMp:
        case datarefGreenLoEgt:
        case datarefGreenHiEgt:
        case datarefYellowLoEgt:
        case datarefYellowLoMegt:
        case datarefRedLoEgt:
        case datarefRedHiEgt:
        case datarefGreenLoCht:
        case datarefGreenHiCht:
        case datarefYellowLoCht:
        case datarefYellowHiCht:
        case datarefRedLoCht:
        case datarefRedHiCht:
        case datarefGreenLoOilp:
        case datarefGreenHiOilp:
        case datarefYellowLoOilp:
        case datarefYellowHiOilp:
        case datarefRedLoOilp:
        case datarefRedHiOilp:
        case datarefGreenLoOilt:
        case datarefGreenHiOilt:
        case datarefYellowLoOilt:
        case datarefYellowHiOilt:
        case datarefRedLoOilt:
        case datarefRedHiOilt:
          break;
      }
    }
    if (receivedAircraftType) {
      state.aircraftType = cStringToDartString(aircraftType);
    }
    if (receivedTailNumber) {
      state.aircraftRegistration = cStringToDartString(tailNumber);
    }
  }

  void updateStateFromMessage(Uint8List message) {
    int header = 5;
    int start = header;

    if (cStringToDartString(message.take(4)) == 'RREF') {
      processDatarefs(XPlaneDatarefResponsePacket.decode(
          message.sublist(5, message.length - 5)));
      return;
    }

    if (cStringToDartString(message.take(4)) != 'DATA') {
      return;
    }

    while (start + XPlaneDataPacket.size <= message.length) {
      XPlaneDataPacket data = XPlaneDataPacket.decode(message.sublist(
        start,
        start + XPlaneDataPacket.size,
      ));
      start = start + XPlaneDataPacket.size;
      switch (data.index) {
        case dataTimes:
          state.time = (data.data[5] * 60.0 * 60.0).toInt();
          break;
        case dataSpeeds:
          state.indicatedAirspeed = data.data[0];
          break;
        case dataMachVsi:
          state.variometer = data.data[2];
          break;
        case dataTrim:
          // TODO: Check this;
          state.elevatorTrim = data.data[0];
          state.aileronTrim = data.data[1];
          state.rudderTrim = data.data[2];
          state.flaps = data.data[3];
          break;
        case dataGear:
          state.gearDownLights = (state.gearDownLights & ~noseGear) |
              ((data.data[0] > 0.99) ? noseGear : 0);
          state.gearUpLights = (state.gearUpLights & ~noseGear) |
              ((data.data[0] < 0.01) ? noseGear : 0);
          state.gearDownLights = (state.gearDownLights & ~leftGear) |
              ((data.data[1] > 0.99) ? leftGear : 0);
          state.gearUpLights = (state.gearUpLights & ~leftGear) |
              ((data.data[1] < 0.01) ? leftGear : 0);
          state.gearDownLights = (state.gearDownLights & ~rightGear) |
              ((data.data[2] > 0.99) ? rightGear : 0);
          state.gearUpLights = (state.gearUpLights & ~rightGear) |
              ((data.data[2] < 0.01) ? rightGear : 0);
          break;
        case dataAngMoment:
          if (version == 11) {
            state.turn = data.data[2] * 180.0 / pi / 3.0;
          }
          break;
        case dataAngVel:
          // X-PLane 10 and 11 renumbered this
          // so pitch and roll goes into this item instead.
          if (data.data[3] < 0.0) {
            // We don't have heading, so this is angular velocity
            state.turn = data.data[2] * 180.0 / pi / 3.0;
            version = 9;
            break;
          }
          state.pitch = data.data[0];
          state.roll = -data.data[1];
          state.trueHeading = data.data[2];
          // Use the magnetic heading
          state.heading = data.data[3];
          version = 11;
          break;
        case dataPitchRoll:
          if (data.data[4] < -900.0) {
            // This is actually slip, from X-Plane 10, 11
            state.slip = data.data[7];
            version = 11;
            break;
          }
          state.pitch = data.data[0];
          state.roll = -data.data[1];
          // Use the magnetic heading
          state.trueHeading = data.data[2];
          state.heading = data.data[3];
          version = 9;
          break;
        case dataAoa:
          if (data.data[7] < -90.0) {
            // This is magnetic compass, from X-Plane 10, 11
            version = 11;
            break;
          }
          state.slip = data.data[7];
          version = 9;
          break;
        case dataLatLongAlt:
          // TODO: Adjust for millibar setting
          state.latitude = data.data[0];
          state.longitude = data.data[1];
          state.altitude = data.data[5];
          state.altitudeAboveGround = data.data[3];
          break;
        case dataRpm:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] = state.engines[i].copyWith(rpm: data.data[i]);
            }
          }
          break;
        case dataManifoldPressure:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] =
                  state.engines[i].copyWith(manifold: data.data[i]);
            }
          }
          break;
        case dataFuelFlow:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] =
                  state.engines[i].copyWith(fuelFlow: data.data[i]);
            }
          }
          break;
        case dataExhaustGasTemperature:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] = state.engines[i].copyWith(
                  exhaustGasTemperature: (data.data[i] - 32.0) * 5.0 / 9.0);
            }
          }
          break;
        case dataCylinderHeadTemperature:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] = state.engines[i].copyWith(
                  cylinderTemperature: (data.data[i] - 32.0) * 5.0 / 9.0);
            }
          }
          break;
        case dataOilPressure:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] =
                  state.engines[i].copyWith(oilPressure: data.data[i]);
            }
          }
          break;

        case dataOilTemperature:
          for (int i = 0; i < maxEngines; i++) {
            if (data.data[i] >= -0.1) {
              state.engines[i] = state.engines[i].copyWith(
                  oilOutTemperature: (data.data[i] - 32.0) * 5.0 / 9.0);
            }
          }
          break;
        default:
          break;
      }
    }
  }

  Future<int> processMessages() async {
    int received = 0;
    Datagram? response;
    response = socket!.receive();
    while (response != null) {
      updateStateFromMessage(response.data);
      response = socket!.receive();
      received++;
    }
    return received;
  }

  double update(double maxRate, double target, double current) {
    if (current < target) {
      return current + min(maxRate, target - current);
    } else {
      return current - min(maxRate, current - target);
    }
  }

  void moveLagInstruments(double timeDelta) {
    double flapsMaxRate = 1.0 / 3.0 * timeDelta;
    double variometerMaxRate = 4000.0 / 9.0 * timeDelta;
    double slipMaxRate = 2.0 / 3.0 * timeDelta;
    state.variometer = update(variometerMaxRate, variometer, state.variometer);
    state.flaps = update(flapsMaxRate, flaps, state.flaps);
    state.slip = update(slipMaxRate, slip, state.slip);
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    bool gotData = false;
    if (socket == null) return current;
    if (scanning) {
      try {
        await scanForXPlane();
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
      double timeDelta = now.difference(lastPoll).inMicroseconds / 1000000.0;
      clock += timeDelta;
      try {
        int received = await processMessages();
        gotData = received > 0;
      } on OSError catch (e) {
        if (e.errorCode == 9) {
          // Bad file descriptor
          await recreateSocket();
        } else {
          rethrow;
        }
      }
      moveLagInstruments(timeDelta);
      lastPoll = now;
      return current.copyWith(
        time: state.time,
        aircraftRegistration: state.aircraftRegistration,
        aircraftType: state.aircraftType,
        latitude: state.latitude,
        longitude: state.longitude,
        indicatedAirspeed: state.indicatedAirspeed,
        variometer: state.variometer,
        slip: state.slip,
        turn: state.turn,
        angularSpeed: state.angularSpeed,
        altitude: state.altitude,
        heading: state.heading,
        trueHeading: state.trueHeading,
        roll: state.roll,
        pitch: state.pitch,
        fuel: state.fuel,
        gearDownLights: state.gearDownLights,
        gearUpLights: state.gearUpLights,
        engines: state.engines,
        flaps: state.flaps,
        propPitch: state.propPitch,
        aileronTrim: state.aileronTrim,
        elevatorTrim: state.elevatorTrim,
        rudderTrim: state.rudderTrim,
        limits: state.limits,
        lastResponse: gotData ? now : null,
      );
    }
  }

  @override
  bool get active => scanning == false;

  @override
  bool get hasAltitudeAboveGround => true;

  @override
  bool get reconnectAfterSleep => true;
}
