import 'dart:math';

import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';

class RandomDataSourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'Random';

  static const double tgtBlend = 0.01;
  Random random = Random();
  InstrumentState targetState = InstrumentState(lastResponse: DateTime(0));
  DateTime nextUpdateTime = DateTime(0);
  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    int i;
    targetState = InstrumentState(
      lastResponse: DateTime(0),
      latitude: -33.9650,
      longitude: 18.6015,
    );
    targetState.engines = [];
    for (i = 0; i < maxEngines; i++) {
      targetState.engines.add(const EngineState());
    }
    UiStateController.setListenOn('');
  }

  @override
  Future<void> close() async {}

  double randFloat(double min, double max) {
    return random.nextDouble() * (max - min) + min;
  }

  int randInt(int min, int max) {
    return random.nextInt(max - min + 1) + min;
  }

  double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    if (now.isAfter(nextUpdateTime)) {
      targetState.aircraftRegistration = 'ZU-ABC';
      targetState.aircraftType = '';
      targetState.indicatedAirspeed = randFloat(0, 120);
      targetState.variometer = randFloat(-1000, 1000);
      targetState.slip = randFloat(-45, 45);
      targetState.turn = randFloat(-1, 1);
      targetState.angularSpeed = randFloat(-36, 36);
      targetState.altitude = randFloat(0, 25000);
      targetState.heading = randFloat(0, 359);
      targetState.trueHeading = targetState.heading;
      targetState.latitude =
          clamp(randFloat(-0.025, 0.025) + targetState.latitude, -90.0, 90.0);
      targetState.longitude = clamp(
          randFloat(-0.025, 0.025) + targetState.longitude, -180.0, 180.0);
      targetState.roll = randFloat(-180, 180);
      targetState.pitch = randFloat(-90, 90);
      targetState.fuel = randFloat(0, 100);
      targetState.gearDownLights = randInt(0, 7);
      targetState.gearUpLights = randInt(0, 7);
      targetState.flaps = randFloat(0, 1);
      targetState.propPitch = randFloat(0, 1);
      targetState.aileronTrim = randFloat(-1, 1);
      targetState.elevatorTrim = randFloat(-1, 1);
      targetState.rudderTrim = randFloat(-1, 1);
      targetState.engines[0] = EngineState(
        magneto: magnetoBoth,
        rpm: randFloat(0, 3000),
        manifold: randFloat(0, 70),
        oilInTemperature: randFloat(0, 50),
        oilOutTemperature: randFloat(0, 120),
        waterTemperature: randFloat(0, 100),
        cylinderTemperature: randFloat(0, 200),
      );
      nextUpdateTime = now.add(const Duration(seconds: 5));
    }
    targetState.time =
        now.difference(DateTime(now.year, now.month, now.day)).inSeconds;
    targetState.lastResponse = now;
    return current.interpolate(targetState, tgtBlend);
  }

  @override
  bool get active => true;

  @override
  bool get hasAltitudeAboveGround => false;

  @override
  bool get reconnectAfterSleep => false;
}
