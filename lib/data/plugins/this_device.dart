import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';

class DeviceMotionManager {
  static bool initialised = false;
  static AccelerometerEvent accelerometerEvent =
      AccelerometerEvent(1, 0, 0, DateTime.now());
  static MagnetometerEvent magnetometerEvent =
      MagnetometerEvent(1, 0, 0, DateTime.now());
  static GyroscopeEvent gyroscopeEvent =
      GyroscopeEvent(0.0, 0.0, 0.0, DateTime.now());
  static UserAccelerometerEvent userAccelerometerEvent =
      UserAccelerometerEvent(1, 0, 0, DateTime.now());
  static StreamSubscription<Position>? positionStream;
  static StreamSubscription<AccelerometerEvent>? accelerometerStream;
  static StreamSubscription<MagnetometerEvent>? magnetometerStream;
  static StreamSubscription<GyroscopeEvent>? gyroscopeStream;
  static StreamSubscription<UserAccelerometerEvent>? userAccelerometerStream;
  static Position gpsPosition = Position(
    latitude: -33.9650,
    longitude: 18.6015,
    timestamp: DateTime.now(),
    accuracy: 100.0,
    altitudeAccuracy: 100.0,
    headingAccuracy: 1.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    floor: 0,
    isMocked: true,
  );

  static Future<void> init() async {
    if (initialised) {
      return;
    }
    accelerometerStream = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        accelerometerEvent = event;
      },
      onError: (error) {},
      cancelOnError: false,
    );

    userAccelerometerStream = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        userAccelerometerEvent = event;
      },
      onError: (error) {},
      cancelOnError: false,
    );

    gyroscopeStream = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        gyroscopeEvent = event;
      },
      onError: (error) {},
      cancelOnError: false,
    );

    magnetometerStream = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        magnetometerEvent = event;
      },
      onError: (error) {},
      cancelOnError: false,
    );

    await Geolocator.requestPermission();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        gpsPosition = position;
      }
    });

    initialised = true;
  }

  void close() {
    unawaited(gyroscopeStream?.cancel());
    gyroscopeStream = null;
    unawaited(positionStream?.cancel());
    positionStream = null;
    unawaited(magnetometerStream?.cancel());
    magnetometerStream = null;
    unawaited(accelerometerStream?.cancel());
    accelerometerStream = null;
    unawaited(userAccelerometerStream?.cancel());
    userAccelerometerStream = null;
    initialised = false;
  }
}

class ThisDeviceDataSourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'This device';

  static const double tgtBlend = 0.9;
  double lastAltitude = 0.0;
  double lastClimbRate = 0.0;
  double lastHeading = 0.0;
  double accelerometerRoll = 0.0;
  double accelerometerPitch = 0.0;
  double accelerometerYaw = 0.0;
  double accelerometerSlip = 0.0;
  InstrumentState targetState = InstrumentState(lastResponse: DateTime(0));

  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    int i;
    targetState = InstrumentState(
      lastResponse: DateTime.now(),
      latitude: -33.9650,
      longitude: 18.6015,
    );
    targetState.engines = [];
    for (i = 0; i < maxEngines; i++) {
      targetState.engines.add(const EngineState());
    }
    UiStateController.setListenOn('');
    await DeviceMotionManager.init();
  }

  @override
  Future<void> close() async {}

  double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void updateOrientation(DateTime now) {
    Duration deltaTime = now.difference(targetState.lastResponse);
    double delta = (deltaTime.inMicroseconds / 1000000.0);
    AccelerometerEvent accelerometerEvent =
        DeviceMotionManager.accelerometerEvent;
    UserAccelerometerEvent userAccelerometerEvent =
        DeviceMotionManager.userAccelerometerEvent;
    MagnetometerEvent magnetometerEvent = DeviceMotionManager.magnetometerEvent;

    accelerometerEvent = AccelerometerEvent(
      accelerometerEvent.x - userAccelerometerEvent.x,
      accelerometerEvent.y - userAccelerometerEvent.y,
      accelerometerEvent.z - userAccelerometerEvent.z,
      userAccelerometerEvent.timestamp,
    );

    if (Settings.landscapeMode) {
      accelerometerSlip = accelerometerEvent.y;
      // Using atan2 to restrict +/- PI
      double roll = atan2(accelerometerEvent.y, accelerometerEvent.x);

      // Using atan to restrict to +/- PI/2
      double pitch = atan(-accelerometerEvent.z /
          (accelerometerEvent.y * sin(roll) +
              accelerometerEvent.x * cos(roll)));

      if ((pitch.isNaN) || (pitch.isInfinite)) {
        pitch = 0.0;
      }

      // Hard iron effect
      MagnetometerEvent v = MagnetometerEvent(0.0, 0.0, 0.0, DateTime.now());

      // Using atan2 to restrict to +/- PI
      double yaw = atan2(
          (magnetometerEvent.x - v.x) * sin(roll) -
              (magnetometerEvent.y - v.y) * cos(roll),
          (magnetometerEvent.z - v.z) * cos(pitch) +
              (magnetometerEvent.y - v.y) * sin(pitch) * sin(roll) +
              (magnetometerEvent.x - v.x) * sin(pitch) * cos(roll));

      yaw = yaw + pi;
      yaw = yaw * 180 / pi;
      // Correct the heading to [0, 360)
      while (yaw < 0) {
        yaw += 360;
      }
      while (yaw > 360) {
        yaw -= 360;
      }

      // The phone roll is around the vertical axis of the screen.
      // The phone pitch is around the horizontal axis of the screen, but
      // 0 degrees is flat.
      // The yaw angle is the rotation of the phone around the line passing through
      // the center of the screen.
      accelerometerRoll = -roll * 180 / pi;
      accelerometerPitch = pitch * 180 / pi;
      accelerometerYaw =
          InstrumentState.circularBlend(accelerometerYaw, yaw, 0.1);
    } else {
      accelerometerSlip = accelerometerEvent.x;
      // Using atan2 to restrict +/- PI
      double roll = atan2(accelerometerEvent.x, accelerometerEvent.y);

      // Using atan to restrict to +/- PI/2
      double pitch = atan(-accelerometerEvent.z /
          (accelerometerEvent.x * sin(roll) +
              accelerometerEvent.y * cos(roll)));

      if ((pitch.isNaN) || (pitch.isInfinite)) {
        pitch = 0.0;
      }

      // Hard iron effect
      MagnetometerEvent v = MagnetometerEvent(0.0, 0.0, 0.0, DateTime.now());

      // Using atan2 to restrict to +/- PI
      double yaw = atan2(
          (magnetometerEvent.y - v.y) * sin(roll) -
              (magnetometerEvent.x - v.x) * cos(roll),
          (magnetometerEvent.z - v.z) * cos(pitch) +
              (magnetometerEvent.x - v.x) * sin(pitch) * sin(roll) +
              (magnetometerEvent.y - v.y) * sin(pitch) * cos(roll));

      yaw = yaw + pi;
      yaw = -yaw;
      yaw = yaw * 180 / pi;
      // Correct the heading to [0, 2*PI)
      while (yaw < 0) {
        yaw += 360;
      }
      while (yaw > 360) {
        yaw -= 360;
      }

      // The phone roll is around the vertical axis of the screen.
      // The phone pitch is around the horizontal axis of the screen, but
      // 0 degrees is flat.
      // The yaw angle is the rotation of the phone around the line passing through
      // the center of the screen.
      accelerometerRoll = roll * 180 / pi;
      accelerometerPitch = pitch * 180 / pi;
      accelerometerYaw =
          InstrumentState.circularBlend(accelerometerYaw, yaw, 0.1);
    }

    lastHeading = targetState.heading;
    targetState.roll = accelerometerRoll;
    targetState.pitch = accelerometerPitch;
    targetState.heading = accelerometerYaw;
    targetState.slip = accelerometerSlip;
    double newHeading = targetState.heading;
    if (newHeading > lastHeading) {
      if (newHeading - lastHeading > 180.0) {
        newHeading -= 360.0;
      }
    } else {
      if (lastHeading - newHeading > 180.0) {
        newHeading += 360.0;
      }
    }
    double headingChange = newHeading - lastHeading;
    double turnRate = headingChange * 60.0 / 720.0 / delta;
    targetState.turn = targetState.turn * 0.9 + turnRate * 0.1;
  }

  void updateMapCoordinates() {
    Position gpsPosition = DeviceMotionManager.gpsPosition;

    targetState.latitude =
        targetState.latitude * 0.9 + 0.1 * gpsPosition.latitude;
    targetState.longitude =
        targetState.longitude * 0.9 + 0.1 * gpsPosition.longitude;
    targetState.altitude =
        targetState.altitude * 0.9 + 0.1 * gpsPosition.altitude * 3.28084;
    targetState.trueHeading = gpsPosition.heading;
    targetState.indicatedAirspeed = gpsPosition.speed * 1.94384;
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    double delta =
        now.difference(targetState.lastResponse).inMilliseconds / 60000.0;
    updateOrientation(now);
    updateMapCoordinates();
    double climbRate = (targetState.altitude - lastAltitude) / delta;
    targetState.aircraftRegistration = 'ZU-ABC';
    targetState.aircraftType = '';
    targetState.variometer = 0.1 * climbRate + 0.9 * lastClimbRate;
    targetState.angularSpeed = 0;
    targetState.time =
        now.difference(DateTime(now.year, now.month, now.day)).inSeconds;
    targetState.lastResponse = now;
    lastAltitude = targetState.altitude;
    lastClimbRate = targetState.variometer;
    return current.interpolate(targetState, tgtBlend);
  }

  @override
  bool get active => true;

  @override
  bool get hasAltitudeAboveGround => false;

  @override
  bool get reconnectAfterSleep => false;
}
