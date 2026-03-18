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

class SimEfisPassiveUDP extends InstrumentDataSourcePlugin {
  @override
  String name = 'SimEfisPassiveUDP';

  BufferedDatagramSocket? socket;
  InternetAddress? host;
  DateTime lastPoll = DateTime(0);
  // laggy instruments
  double slip = 0.0;
  double variometer = 0.0;
  // interpolate position
  double flaps = 0.0;
  // Internal time keeping
  double clock = 0.0;
  Simulator simulator = Simulator.FlightGear;
  bool haveTrueHeading = false;
  static const int maxHeadingHistory = 5;
  List<HeadingRecord> headings = [];
  int nextHeadingRecord = 0;
  bool haveTurnRate = false;

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
    headings = [];
    for (i = 0; i < maxHeadingHistory; i++) {
      headings.add(const HeadingRecord(time: 0.0, heading: 0.0));
    }
    this.simulator = simulator;
    await recreateSocket();
    lastPoll = DateTime.now();
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

  void updateStateFromMessage(String message) {
    List<String> responses = message.split(';');
    double floatValue = 0.0;
    int intValue = 0;
    int engine;

    for (String response in responses) {
      try {
        List<String> parts = response.split(':');
        String type = parts[0];
        switch (type) {
          case 'TIME':
            state.time = int.parse(parts[1]);
            break;
          case 'ACFT':
            state.aircraftType = parts[1];
            break;
          case 'NENG':
            intValue = int.parse(parts[1]);
            state.limits = state.limits
                .copyWith(numberOfEngines: min(max(intValue, 0), maxEngines));
            break;
          case 'KIAS':
            state.indicatedAirspeed = double.parse(parts[1]);
            break;
          case 'VSIF':
            variometer = double.parse(parts[1]);
            break;
          case 'SLIP':
            slip = double.parse(parts[1]) * 6.0;
            break;
          case 'TURN':
            state.turn = double.parse(parts[1]);
            haveTurnRate = true;
            break;
          case 'ALTF':
            state.altitude = double.parse(parts[1]);
            break;
          case 'AGLF':
            state.altitudeAboveGround = double.parse(parts[1]);
            break;
          case 'HEAD':
            state.heading = double.parse(parts[1]);
            if (!haveTrueHeading) {
              state.trueHeading = state.heading;
            }
            headings[nextHeadingRecord] = HeadingRecord(
              time: clock,
              heading: state.heading,
            );
            nextHeadingRecord = (nextHeadingRecord + 1) % maxHeadingHistory;
            break;
          case 'HDTR':
            state.trueHeading = double.parse(parts[1]);
            haveTrueHeading = true;
            break;
          case 'ROLL':
            state.roll = -double.parse(parts[1]);
            break;
          case 'PITC':
            state.pitch = double.parse(parts[1]);
            break;
          case 'FUEL':
            // TODO: Don't know the fuel measurement
            state.fuel = double.parse(parts[1]);
            break;
          case 'LGLT':
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~leftGear) |
                ((floatValue > 0.99) ? leftGear : 0);
            state.gearUpLights = (state.gearUpLights & ~leftGear) |
                ((floatValue < 0.01) ? leftGear : 0);
            break;
          case 'LGRT':
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~rightGear) |
                ((floatValue > 0.99) ? rightGear : 0);
            state.gearUpLights = (state.gearUpLights & ~rightGear) |
                ((floatValue < 0.01) ? rightGear : 0);
            break;
          case 'LGCT':
            floatValue = double.parse(parts[1]);
            state.gearDownLights = (state.gearDownLights & ~noseGear) |
                ((floatValue > 0.99) ? noseGear : 0);
            state.gearUpLights = (state.gearUpLights & ~noseGear) |
                ((floatValue < 0.01) ? noseGear : 0);
            break;
          case 'RPMS':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] =
                  state.engines[engine].copyWith(rpm: double.parse(parts[2]));
            }
            break;
          case 'MANP':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(manifold: double.parse(parts[2]));
            }
            break;
          case 'OILF':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine].copyWith(
                  oilOutTemperature:
                      (double.parse(parts[2]) - 32.0) * 5.0 / 9.0);
            }
            break;
          case 'CHTF':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine].copyWith(
                  cylinderTemperature:
                      (double.parse(parts[2]) - 32.0) * 5.0 / 9.0);
            }
            break;
          case 'EGTF':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine].copyWith(
                  exhaustGasTemperature:
                      (double.parse(parts[2]) - 32.0) * 5.0 / 9.0);
            }
            break;
          case 'OILP':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(oilPressure: double.parse(parts[2]) / 16.0 * 2.036);
            }
            break;
          case 'FFGP':
            engine = int.parse(parts[1]);
            if ((engine >= 0) && (engine < state.limits.numberOfEngines)) {
              state.engines[engine] = state.engines[engine]
                  .copyWith(fuelFlow: double.parse(parts[2]));
            }
            break;
          case 'FLAP':
            flaps = double.parse(parts[1]);
            break;
          case 'TRMA':
            state.aileronTrim = -double.parse(parts[1]);
            break;
          case 'TRME':
            state.elevatorTrim = -double.parse(parts[1]);
            break;
          case 'TRMR':
            state.rudderTrim = -double.parse(parts[1]);
            break;
          case 'LATD':
            state.latitude = double.parse(parts[1]);
            break;
          case 'LONG':
            state.longitude = double.parse(parts[1]);
            break;
        }
      } catch (e) {
        // We do nothing here for the moment :-(
      }
    }
  }

  int processMessages() {
    int received = 0;
    Datagram? response;
    response = socket!.receive();
    while (response != null) {
      updateStateFromMessage(cStringToDartString(response.data));
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
    if (!haveTurnRate) {
      state.turn = 0.95 * state.turn + 0.05 * turnRate() / 3.0;
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

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    bool gotData = false;
    if (socket == null) return current;
    double timeDelta = now.difference(lastPoll).inMicroseconds / 1000000.0;
    clock += timeDelta;
    try {
      int received = processMessages();
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
      altitudeAboveGround: state.altitudeAboveGround,
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

  @override
  bool get active => true;

  @override
  bool get hasAltitudeAboveGround => true;

  @override
  bool get reconnectAfterSleep => true;
}
