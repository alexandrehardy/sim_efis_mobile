const int leftGear = 1;
const int rightGear = 2;
const int noseGear = 4;

const int maxEngines = 4;
const int magnetoOff = 0;
const int magnetoRight = 1;
const int magnetoLeft = 2;
const int magnetoBoth = 3;

class EngineState {
  final int magneto;
  final double rpm;
  final double manifold; // in IN Hg
  final double oilInTemperature; // in degrees C
  final double oilOutTemperature;
  final double waterTemperature;
  final double cylinderTemperature;
  final double exhaustGasTemperature;
  final double fuelFlow;
  final double oilPressure;

  const EngineState({
    this.magneto = 0,
    this.rpm = 0.0,
    this.manifold = 0.0,
    this.oilInTemperature = 0.0,
    this.oilOutTemperature = 0.0,
    this.waterTemperature = 0.0,
    this.cylinderTemperature = 0.0,
    this.exhaustGasTemperature = 0.0,
    this.fuelFlow = 0.0,
    this.oilPressure = 0.0,
  });

  EngineState copyWith({
    int? magneto,
    double? rpm,
    double? manifold,
    double? oilInTemperature,
    double? oilOutTemperature,
    double? waterTemperature,
    double? cylinderTemperature,
    double? exhaustGasTemperature,
    double? fuelFlow,
    double? oilPressure,
  }) {
    return EngineState(
      magneto: magneto ?? this.magneto,
      rpm: rpm ?? this.rpm,
      manifold: manifold ?? this.manifold,
      oilInTemperature: oilInTemperature ?? this.oilInTemperature,
      oilOutTemperature: oilOutTemperature ?? this.oilOutTemperature,
      waterTemperature: waterTemperature ?? this.waterTemperature,
      cylinderTemperature: cylinderTemperature ?? this.cylinderTemperature,
      exhaustGasTemperature:
          exhaustGasTemperature ?? this.exhaustGasTemperature,
      fuelFlow: fuelFlow ?? this.fuelFlow,
      oilPressure: oilPressure ?? this.oilPressure,
    );
  }
}

class AircraftLimits {
  final int numberOfEngines;
  final double vr; // rotate speed
  final double vx; // best angle of climb
  final double vy; // best rate of climb
  final double
      vno; // maximum normal speed (end of green arc, start of yellow arc)
  final double vne; // do not exceed speed (end of yellow arc)
  final double vso; // stall speed with flaps and gear (start of white arc)
  final double vs; // stall speed (start of green arc)
  final double vfe; // maximum flap extended speed (end of white arc)
  final double maxFuel;
  final double minRpm;
  final double maxRpm;
  final double oilTempMin; // These are the green limits
  final double oilTempMax;
  final double waterTempMin;
  final double waterTempMax;
  final double cylinderTempMin;
  final double cylinderTempMax;
  final double exhaustGasTempMin;
  final double exhaustGasTempMax;
  final double oilPressureMin;
  final double oilPressureMax;
  final double manifoldPressureMin;
  final double manifoldPressureMax;

  const AircraftLimits({
    this.numberOfEngines = 1,
    this.vr = 42.0,
    this.vx = 65.0,
    this.vy = 72.0,
    this.vno = 100.0,
    this.vne = 140.0,
    this.vso = 40.0,
    this.vs = 45.0,
    this.vfe = 80.0,
    this.maxFuel = 150.0,
    this.minRpm = 500.0,
    this.maxRpm = 3500.0,
    this.oilTempMin = 20.0,
    this.oilTempMax = 100.0,
    this.waterTempMin = 5.0,
    this.waterTempMax = 80.0,
    this.cylinderTempMin = 70.0,
    this.cylinderTempMax = 250.0,
    this.exhaustGasTempMin = 0.0,
    this.exhaustGasTempMax = 1000.0,
    this.oilPressureMin = 0.0,
    this.oilPressureMax = 100.0,
    this.manifoldPressureMin = 10.0,
    this.manifoldPressureMax = 35.0,
  });

  AircraftLimits copyWith({
    int? numberOfEngines,
    double? vr,
    double? vx,
    double? vy,
    double? vno,
    double? vne,
    double? vso,
    double? vs,
    double? vfe,
    double? maxFuel,
    double? minRpm,
    double? maxRpm,
    double? oilTempMin,
    double? oilTempMax,
    double? waterTempMin,
    double? waterTempMax,
    double? cylinderTempMin,
    double? cylinderTempMax,
    double? exhaustGasTempMin,
    double? exhaustGasTempMax,
    double? oilPressureMin,
    double? oilPressureMax,
    double? manifoldPressureMin,
    double? manifoldPressureMax,
  }) {
    return AircraftLimits(
      numberOfEngines: numberOfEngines ?? this.numberOfEngines,
      vr: vr ?? this.vr,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      vno: vno ?? this.vno,
      vne: vne ?? this.vne,
      vso: vso ?? this.vso,
      vs: vs ?? this.vs,
      vfe: vfe ?? this.vfe,
      maxFuel: maxFuel ?? this.maxFuel,
      minRpm: maxRpm ?? this.minRpm,
      maxRpm: maxRpm ?? this.maxRpm,
      oilTempMin: oilTempMin ?? this.oilTempMin,
      oilTempMax: oilTempMax ?? this.oilTempMax,
      waterTempMin: waterTempMin ?? this.waterTempMin,
      waterTempMax: waterTempMax ?? this.waterTempMax,
      cylinderTempMin: cylinderTempMin ?? this.cylinderTempMin,
      cylinderTempMax: cylinderTempMax ?? this.cylinderTempMax,
      exhaustGasTempMin: exhaustGasTempMin ?? this.exhaustGasTempMin,
      exhaustGasTempMax: exhaustGasTempMax ?? this.exhaustGasTempMax,
      oilPressureMin: oilPressureMin ?? this.oilPressureMin,
      oilPressureMax: oilPressureMax ?? this.oilPressureMax,
      manifoldPressureMin: manifoldPressureMin ?? this.manifoldPressureMin,
      manifoldPressureMax: manifoldPressureMax ?? this.manifoldPressureMax,
    );
  }

  String encode(String aircraft) {
    List<String> lines = [];
    lines.add('aircraft = $aircraft');
    lines.add('nr_engines = $numberOfEngines');
    lines.add('vr = $vr');
    lines.add('vx = $vx');
    lines.add('vy = $vy');
    lines.add('vno = $vno');
    lines.add('vne = $vne');
    lines.add('vso = $vso');
    lines.add('vs = $vs');
    lines.add('vfe = $vfe');
    lines.add('max_fuel = $maxFuel');
    lines.add('min_rpm = $minRpm');
    lines.add('max_rpm = $maxRpm');
    lines.add('oil_temp_min = $oilTempMin');
    lines.add('oil_temp_max = $oilTempMax');
    lines.add('water_temp_min = $waterTempMin');
    lines.add('water_temp_max = $waterTempMax');
    lines.add('cylinder_temp_min = $cylinderTempMin');
    lines.add('cylinder_temp_max = $cylinderTempMax');
    lines.add('exhaust_gas_temp_min = $exhaustGasTempMin');
    lines.add('exhaust_gas_temp_max = $exhaustGasTempMax');
    lines.add('oil_pressure_min = $oilPressureMin');
    lines.add('oil_pressure_max = $oilPressureMax');
    lines.add('manifold_pressure_min = $manifoldPressureMin');
    lines.add('manifold_pressure_max = $manifoldPressureMax');
    return lines.join('\n');
  }

  static AircraftLimits decode(String contents) {
    Map<String, double> values = {};
    List<String> lines = contents.split('\n');
    lines = lines.where((line) => line.trim() != '').toList();
    for (String line in lines) {
      List<String> parts = line.split('=').map((e) => e.trim()).toList();
      if (parts.length != 2) {
        continue;
      }
      String key = parts[0];
      double? value = double.tryParse(parts[1]);
      if (value == null) {
        continue;
      }
      values[key] = value;
    }
    return AircraftLimits(
      numberOfEngines: (values['nr_engines'] ?? 1.0).toInt(),
      vr: values['vr'] ?? 0.0,
      vx: values['vx'] ?? 0.0,
      vy: values['vy'] ?? 0.0,
      vno: values['vno'] ?? 0.0,
      vne: values['vne'] ?? 0.0,
      vso: values['vso'] ?? 0.0,
      vs: values['vs'] ?? 0.0,
      vfe: values['vfe'] ?? 0.0,
      maxFuel: values['max_fuel'] ?? 0.0,
      minRpm: values['min_rpm'] ?? 0.0,
      maxRpm: values['max_rpm'] ?? 0.0,
      oilTempMin: values['oil_temp_min'] ?? 0.0,
      oilTempMax: values['oil_temp_max'] ?? 0.0,
      waterTempMin: values['water_temp_min'] ?? 0.0,
      waterTempMax: values['water_temp_max'] ?? 0.0,
      cylinderTempMin: values['cylinder_temp_min'] ?? 0.0,
      cylinderTempMax: values['cylinder_temp_max'] ?? 0.0,
      exhaustGasTempMin: values['exhaust_gas_temp_min'] ?? 0.0,
      exhaustGasTempMax: values['exhaust_gas_temp_max'] ?? 0.0,
      oilPressureMin: values['oil_pressure_min'] ?? 0.0,
      oilPressureMax: values['oil_pressure_max'] ?? 0.0,
      manifoldPressureMin: values['manifold_pressure_min'] ?? 0.0,
      manifoldPressureMax: values['manifold_pressure_max'] ?? 0.0,
    );
  }
}

class InstrumentState {
  int time; // in seconds, since midnight
  String aircraftRegistration;
  String aircraftType;
  double latitude;
  double longitude;
  double indicatedAirspeed; // in knots
  double variometer; // in ft/min
  double slip; // in degrees
  double turn; // -1 to 1 for amount of 2 min turn
  double angularSpeed; // degrees per second
  double altitude; // in feet
  double altitudeAboveGround; // in feet
  double heading; // in degrees magnetic
  double trueHeading;
  double roll; // degrees left and right of horizontal
  double pitch; // degrees up and down of horizontal
  double fuel; // available fuel (lbs)
  int gearDownLights;
  int gearUpLights;
  List<EngineState> engines;
  double flaps; // flaps setting, 0-1
  double propPitch; // 0-1
  double aileronTrim; // -1 to 1
  double elevatorTrim; // -1 to 1
  double rudderTrim; // -1 to 1
  AircraftLimits limits;
  DateTime lastResponse;

  InstrumentState({
    this.time = 0,
    this.aircraftRegistration = '',
    this.aircraftType = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.indicatedAirspeed = 0.0,
    this.variometer = 0.0,
    this.slip = 0.0,
    this.turn = 0.0,
    this.angularSpeed = 0.0,
    this.altitude = 0.0,
    this.altitudeAboveGround = 0.0,
    this.heading = 0.0,
    this.trueHeading = 0.0,
    this.roll = 0.0,
    this.pitch = 0.0,
    this.fuel = 0.0,
    this.gearDownLights = 0,
    this.gearUpLights = noseGear | leftGear | rightGear,
    this.engines = const [
      EngineState(),
      EngineState(),
      EngineState(),
      EngineState(),
    ],
    this.flaps = 0.0,
    this.propPitch = 0.0,
    this.aileronTrim = 0.0,
    this.elevatorTrim = 0.0,
    this.rudderTrim = 0.0,
    this.limits = const AircraftLimits(),
    required this.lastResponse,
  });

  InstrumentState copyWith({
    int? time,
    String? aircraftRegistration,
    String? aircraftType,
    double? latitude,
    double? longitude,
    double? indicatedAirspeed,
    double? variometer,
    double? slip,
    double? turn,
    double? angularSpeed,
    double? altitude,
    double? altitudeAboveGround,
    double? heading,
    double? trueHeading,
    double? roll,
    double? pitch,
    double? fuel,
    int? gearDownLights,
    int? gearUpLights,
    List<EngineState>? engines,
    double? flaps,
    double? propPitch,
    double? aileronTrim,
    double? elevatorTrim,
    double? rudderTrim,
    AircraftLimits? limits,
    DateTime? lastResponse,
  }) {
    return InstrumentState(
      time: time ?? this.time,
      aircraftType: aircraftType ?? this.aircraftType,
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      indicatedAirspeed: indicatedAirspeed ?? this.indicatedAirspeed,
      variometer: variometer ?? this.variometer,
      slip: slip ?? this.slip,
      turn: turn ?? this.turn,
      angularSpeed: angularSpeed ?? this.angularSpeed,
      altitude: altitude ?? this.altitude,
      altitudeAboveGround: altitudeAboveGround ?? this.altitudeAboveGround,
      heading: heading ?? this.heading,
      trueHeading: trueHeading ?? this.trueHeading,
      roll: roll ?? this.roll,
      pitch: pitch ?? this.pitch,
      fuel: fuel ?? this.fuel,
      gearDownLights: gearDownLights ?? this.gearDownLights,
      gearUpLights: gearUpLights ?? this.gearUpLights,
      engines: engines ?? this.engines,
      flaps: flaps ?? this.flaps,
      propPitch: propPitch ?? this.propPitch,
      aileronTrim: aileronTrim ?? this.aileronTrim,
      elevatorTrim: elevatorTrim ?? this.elevatorTrim,
      rudderTrim: rudderTrim ?? this.rudderTrim,
      limits: limits ?? this.limits,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  static double circularBlend(
    double source,
    double target,
    double rate, {
    double minAngle = 0.0,
    double maxAngle = 360.0,
  }) {
    double srcBlend = 1.0 - rate;
    double tgtBlend = rate;
    double result;
    if (target - source > 180.0) {
      target = target - 360.0;
    }
    if (source - target > 180.0) {
      target = target + 360.0;
    }
    result = source * srcBlend + target * tgtBlend;
    while (result < minAngle) {
      result += 360.0;
    }
    while (result > maxAngle) {
      result -= 360.0;
    }
    return result;
  }

  InstrumentState interpolate(InstrumentState targetState, double rate) {
    double srcBlend = 1.0 - rate;
    double tgtBlend = rate;
    InstrumentState newState = copyWith(
      time: targetState.time,
      limits: targetState.limits,
      aircraftRegistration: targetState.aircraftRegistration,
      aircraftType: targetState.aircraftType,
      longitude: circularBlend(
        longitude,
        targetState.longitude,
        rate,
        minAngle: -180.0,
        maxAngle: 180.0,
      ),
      latitude: latitude * srcBlend + targetState.latitude * tgtBlend,
      indicatedAirspeed: indicatedAirspeed * srcBlend +
          targetState.indicatedAirspeed * tgtBlend,
      variometer: variometer * srcBlend + targetState.variometer * tgtBlend,
      slip: slip * srcBlend + targetState.slip * tgtBlend,
      turn: turn * srcBlend + targetState.turn * tgtBlend,
      angularSpeed:
          angularSpeed * srcBlend + targetState.angularSpeed * tgtBlend,
      altitude: altitude * srcBlend + targetState.altitude * tgtBlend,
      altitudeAboveGround: altitudeAboveGround * srcBlend +
          targetState.altitudeAboveGround * tgtBlend,
      heading: circularBlend(heading, targetState.heading, rate,
          minAngle: 0.0, maxAngle: 360.0),
      trueHeading: circularBlend(trueHeading, targetState.trueHeading, rate,
          minAngle: 0.0, maxAngle: 360.0),
      roll: circularBlend(roll, targetState.roll, rate,
          minAngle: -180.0, maxAngle: 180.0),
      pitch: circularBlend(pitch, targetState.pitch, rate,
          minAngle: -180.0, maxAngle: 180.0),
      fuel: fuel * srcBlend + targetState.fuel * tgtBlend,
      flaps: flaps * srcBlend + targetState.flaps * tgtBlend,
      propPitch: propPitch * srcBlend + targetState.propPitch * tgtBlend,
      aileronTrim: aileronTrim * srcBlend + targetState.aileronTrim * tgtBlend,
      elevatorTrim:
          elevatorTrim * srcBlend + targetState.elevatorTrim * tgtBlend,
      rudderTrim: rudderTrim * srcBlend + targetState.rudderTrim * tgtBlend,
      gearDownLights: targetState.gearDownLights,
      gearUpLights: targetState.gearUpLights,
      engines: List.from(engines),
      lastResponse: targetState.lastResponse,
    );

    for (int i = 0; i < maxEngines; i++) {
      newState.engines[i] = engines[i].copyWith(
        magneto: targetState.engines[i].magneto,
        rpm: engines[i].rpm * srcBlend + targetState.engines[i].rpm * tgtBlend,
        manifold: engines[i].manifold * srcBlend +
            targetState.engines[i].manifold * tgtBlend,
        oilInTemperature: engines[i].oilInTemperature * srcBlend +
            targetState.engines[i].oilInTemperature * tgtBlend,
        oilOutTemperature: engines[i].oilOutTemperature * srcBlend +
            targetState.engines[i].oilOutTemperature * tgtBlend,
        waterTemperature: engines[i].waterTemperature * srcBlend +
            targetState.engines[i].waterTemperature * tgtBlend,
        cylinderTemperature: engines[i].cylinderTemperature * srcBlend +
            targetState.engines[i].cylinderTemperature * tgtBlend,
        exhaustGasTemperature: engines[i].exhaustGasTemperature * srcBlend +
            targetState.engines[i].exhaustGasTemperature * tgtBlend,
        fuelFlow: engines[i].fuelFlow * srcBlend +
            targetState.engines[i].fuelFlow * tgtBlend,
        oilPressure: engines[i].oilPressure * srcBlend +
            targetState.engines[i].oilPressure * tgtBlend,
      );
    }
    return newState;
  }
}
