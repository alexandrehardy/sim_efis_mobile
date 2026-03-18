import 'dart:io';
import 'dart:math';

import 'package:sim_efis/data/heading_record.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/data/utils.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/settings.dart';

class DeviceLinkSourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'DeviceLink';

  static const int maxHeadingHistory = 5;
  static const int opVersion = 2; // Device link version
  static const int opTimeOfDayHours = 20; // time of day in hours
  static const int opPlaneName = 22; // name of plane
  static const int opNumberOfEngines = 28; // number of engines
  static const int opAirspeedIndicatedKmh = 30; // airspeed indicated (km/h)
  static const int opVariometerMs = 32; // variometer (m/s)
  static const int opSlip = 34; // slip in degrees (-45, 45)
  static const int opTurn = 36; // turn indicator (-1, 1)
  static const int opAngularSpeed = 38; // angular speed (degr/s)
  static const int opAltimeterMetres = 40; // altimeter (m)
  static const int opAzimuth = 42; // azimuth (deg) (0, 359)
  static const int opBeaconAzimuth = 44; // beacon azimuth (deg) (0, 359)
  static const int opRoll = 46; // roll (-180, 180)
  static const int opPitch = 48; // pitch (-90, 90)
  static const int opFuel = 50; // fuel (kg)
  static const int opGearLeft = 56; // gear l (0, 1)
  static const int opGearRight = 58; // gear r (0, 1)
  static const int opGearCentre = 60; // gear c (0, 1)
  static const int opMagneto = 62; // magneto 0, 1, 2, 3
  static const int opRpm = 64; // rpm
  static const int opManifoldPressure = 66; // manifold pressure (bar)
  static const int opOilTempIn = 68; // oil temp in (deg C)
  static const int opOilTempOut = 70; // oil temp out (deg C)
  static const int opWaterTemp = 72; // water temp (deg C)
  static const int opCylinderTemp = 74; // cylinder temp (deg C)
  static const int opFlaps = 82; // flaps
  static const int opPropPitch = 92; // prop-pitch
  static const int opAileronTrim = 94; // aileron trim
  static const int opElevatorTrim = 96; // elevator trim
  static const int opRudderTrim = 98; // rudder trim

  BufferedDatagramSocket? socket;
  InternetAddress? host;
  int connectPort = 11946; // The port on which to send data
  bool scanning = true;
  DateTime nextScanTime = DateTime(0);
  DateTime lastPoll = DateTime(0);
  // laggy instruments
  double slip = 0.0;
  double variometer = 0.0;
  // interpolate position
  double flaps = 0.0;
  // il2's turn indicator is not
  // so great, use heading difference
  // instead
  List<HeadingRecord> headings = [];
  int nextHeadingRecord = 0;
  double turn = 0.0;
  // Internal time keeping
  double clock = 0.0;
  String scanHost = '192.168.1';
  Simulator simulator = Simulator.IL2_1946;

  InstrumentState state = InstrumentState(lastResponse: DateTime(0));

  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    int i;
    headings = [];
    for (i = 0; i < maxHeadingHistory; i++) {
      headings.add(const HeadingRecord(time: 0.0, heading: 0.0));
    }
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
    socket?.close();
    socket = null;
  }

  void sendMessage(String message) {
    socket!.send(message.codeUnits, host!, connectPort);
  }

  void scanForDeviceLink() {
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
        Logger.log('DeviceLink: Polling subnet $subnet.0/24');
        for (i = 1; i < 254; i++) {
          // Ask for version and time and wait for response
          socket!.send(
            'R/2'.codeUnits,
            InternetAddress('$subnet.$i', type: InternetAddressType.IPv4),
            connectPort,
          );
        }
      } else {
        // Ask for time and wait for response
        Logger.log('DeviceLink: Polling host $scanHost');
        socket!.send(
          'R/2'.codeUnits,
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
        String version =
            cStringToDartString(response.data.take(50)).replaceAll('A/2\\', '');
        Logger.log(
            'DeviceLink: Got response from ${host!.address}: DeviceLink version: $version');
        response = socket!.receive();
      }
    }
  }

  void deviceLinkUpdateStateFromMessage(String message) {
    if (!message.startsWith('A/')) return;
    List<String> responses = message.split('/');
    double floatValue = 0.0;
    int intValue = 0;
    int engine;

    for (String response in responses) {
      if (response.trim() == 'A') continue;
      try {
        List<String> parts = response.split('\\');
        int type = int.parse(parts[0]);
        switch (type) {
          case opTimeOfDayHours:
            floatValue = double.parse(parts[1]);
            state.time = (floatValue * 60 * 60).toInt();
            break;
          case opPlaneName:
            state.aircraftType = parts[1];
            break;
          case opNumberOfEngines:
            intValue = int.parse(parts[1]);
            state.limits = state.limits
                .copyWith(numberOfEngines: min(max(intValue, 0), maxEngines));
            break;
          case opAirspeedIndicatedKmh:
            state.indicatedAirspeed = double.parse(parts[1]) * 0.539957;
            break;
          case opVariometerMs:
            // TODO: This seems high
            variometer = double.parse(parts[1]) * 3.28084 * 60;
            break;
          case opSlip:
            slip = double.parse(parts[1]);
            break;
          case opTurn:
            // TODO: This isn't minutes. Don't know what it is.
            turn = double.parse(parts[1]);
            break;
          case opAngularSpeed:
            state.angularSpeed = double.parse(parts[1]);
            break;
          case opAltimeterMetres:
            state.altitude = double.parse(parts[1]) * 3.28084;
            break;
          case opAzimuth:
            state.heading = double.parse(parts[1]);
            // Fake the true heading
            state.trueHeading = state.heading;
            headings[nextHeadingRecord] = HeadingRecord(
              time: clock,
              heading: state.heading,
            );
            nextHeadingRecord = (nextHeadingRecord + 1) % maxHeadingHistory;
            break;
          case opBeaconAzimuth:
            break;
          case opRoll:
            state.roll = double.parse(parts[1]);
            break;
          case opPitch:
            state.pitch = double.parse(parts[1]);
            break;
          case opFuel:
            state.fuel = double.parse(parts[1]) * 2.20462;
            break;
          case opGearLeft:
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~leftGear) |
                ((floatValue > 0.99) ? leftGear : 0);
            state.gearUpLights = (state.gearUpLights & ~leftGear) |
                ((floatValue < 0.01) ? leftGear : 0);
            break;
          case opGearRight:
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~rightGear) |
                ((floatValue > 0.99) ? rightGear : 0);
            state.gearUpLights = (state.gearUpLights & ~rightGear) |
                ((floatValue < 0.01) ? rightGear : 0);
            break;
          case opGearCentre:
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~noseGear) |
                ((floatValue > 0.99) ? noseGear : 0);
            state.gearUpLights = (state.gearUpLights & ~noseGear) |
                ((floatValue < 0.01) ? noseGear : 0);
            break;
          case opMagneto:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] =
                  state.engines[engine].copyWith(magneto: int.parse(parts[2]));
            }
            break;
          case opRpm:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] =
                  state.engines[engine].copyWith(rpm: double.parse(parts[2]));
            }
            break;
          case opManifoldPressure:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(manifold: double.parse(parts[2]) * 29.53);
            }
            break;
          case opOilTempIn:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(oilInTemperature: double.parse(parts[2]));
            }
            break;
          case opOilTempOut:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(oilOutTemperature: double.parse(parts[2]));
            }
            break;
          case opWaterTemp:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(waterTemperature: double.parse(parts[2]));
            }
            break;
          case opCylinderTemp:
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(cylinderTemperature: double.parse(parts[2]));
            }
            break;
          case opFlaps:
            flaps = (double.parse(parts[1]) + 1.0) / 2.0;
            break;
          case opPropPitch:
            state.propPitch = double.parse(parts[1]);
            break;
          case opAileronTrim:
            state.aileronTrim = double.parse(parts[1]);
            break;
          case opElevatorTrim:
            state.elevatorTrim = double.parse(parts[1]);
            break;
          case opRudderTrim:
            state.rudderTrim = double.parse(parts[1]);
            break;
        }
      } catch (e) {
        // We do nothing here for the moment :-(
      }
    }
  }

  int deviceLinkProcessMessages() {
    int received = 0;
    Datagram? response;
    response = socket!.receive();
    while (response != null) {
      deviceLinkUpdateStateFromMessage(cStringToDartString(response.data));
      response = socket!.receive();
      received = received + 1;
    }
    return received;
  }

  void deviceLinkPollState() {
    int i;
    sendMessage('R/20/22/28');
    sendMessage('R/30/32/34/36/38/40/42/46/48');
    sendMessage('R/50/56/58/60');
    sendMessage('R/82/92/94/96/98');
    for (i = 0; i < state.limits.numberOfEngines; i++) {
      sendMessage('R/62\\$i/64\\$i/66\\$i/68\\$i/70\\$i/72\\$i/74\\$i');
    }
  }

  double turnRate() {
    double minTime = headings[0].time;
    double maxTime = minTime;
    double minHeading = headings[0].heading;
    double maxHeading = minHeading;
    int i;

    for (i = 1; i < maxHeadingHistory; i++) {
      if (headings[i].time < minTime) {
        minTime = headings[i].time;
        minHeading = headings[i].heading;
      }
      if (headings[i].time > maxTime) {
        maxTime = headings[i].time;
        maxHeading = headings[i].heading;
      }
    }

    if (maxHeading > minHeading) {
      if (maxHeading - minHeading > 180.0) {
        minHeading += 360.0;
      }
    } else {
      if (minHeading - maxHeading > 180.0) {
        maxHeading += 360.0;
      }
    }

    if (maxTime - minTime < 0.02) {
      // there is no data here.
      return 0.0;
    }
    return (maxHeading - minHeading) / (maxTime - minTime);
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
    state.turn = 0.95 * state.turn + 0.05 * turnRate() / 3.0;
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    bool gotData = false;
    if (socket == null) return current;
    if (scanning) {
      try {
        scanForDeviceLink();
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
        int received = deviceLinkProcessMessages();
        gotData = received > 0;
        deviceLinkPollState();
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
  bool get hasAltitudeAboveGround => false;

  @override
  bool get reconnectAfterSleep => true;
}
