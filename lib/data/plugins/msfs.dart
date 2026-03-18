// Uses https://github.com/scott-vincent/instrument-data-link
// Uses v1.6.2
// GPS (lat, long) in https://github.com/alexandrehardy/instrument-data-link

import 'dart:io';
import 'dart:typed_data';

import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/data/utils.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/settings.dart';

class InstrumentDataRequest {
  final int requestedSize;
  final bool wantFullData;
  final int writeEventId; // UNUSED
  final double writeValue; // UNUSED

  const InstrumentDataRequest({
    required this.requestedSize,
    required this.wantFullData,
    this.writeEventId = 0,
    this.writeValue = 0.0,
  });

  Uint8List encode() {
    ByteData data = ByteData(16);
    data.setInt32(0, requestedSize, Endian.little);
    data.setInt32(8, wantFullData ? 1 : 0, Endian.little);
    // Don't send the writeData, because we get no response if we do.
    //data.setInt32(16, writeEventId, Endian.little);
    //data.setFloat64(24, writeValue, Endian.little);
    return data.buffer.asUint8List();
  }
}

class MSFSSimVars {
  static const int stringOffset = 2048;
  static const int connectedOffset = 0;

  // All Jetbridge vars must come first
  static const int apuMasterSwOffset = 8;
  static const int jbApuStartOffset = 16;
  static const int jbApuStartAvailOffset = 24;
  static const int apuBleedOffset = 32;
  static const int elecBat1Offset = 40;
  static const int elecBat2Offset = 48;
  static const int jbFlapsIndexOffset = 56;
  static const int jbParkBrakePosOffset = 64;
  static const int jbAutopilot1Offset = 72;
  static const int jbAutopilot2Offset = 80;
  static const int jbAutothrustOffset = 88;
  static const int jbAutopilotHeadingOffset = 96;
  static const int jbAutopilotVerticalSpeedOffset = 104;
  static const int jbAutopilotFpaOffset = 112;
  static const int jbManagedSpeedOffset = 120;
  static const int jbManagedHeadingOffset = 128;
  static const int jbManagedAltitudeOffset = 136;
  static const int jbLateralModeOffset = 144;
  static const int jbVerticalModeOffset = 152;
  static const int jbLocModeOffset = 160;
  static const int jbApprModeOffset = 168;
  static const int jbAutothrustModeOffset = 176;
  static const int jbAutobrakeOffset = 184;
  static const int jbLeftBrakePedalOffset = 192;
  static const int jbRightBrakePedalOffset = 200;
  static const int jbEngineEgtOffset = 208;
  static const int jbEngineFuelFlowOffset = 216;

  // Vars required for all panels (screensaver, aircraft identification etc.)
  static const int aircraftOffset = 224;
  static const int cruiseSpeedOffset = 256;
  static const int dcVoltsOffset = 264;

  // Vars for Power/Lights panel
  static const int lightStatesOffset = 272;
  static const int tfFlapsCountOffset = 280;
  static const int tfFlapsIndexOffset = 288;
  static const int parkingBrakeOnOffset = 296;
  static const int apuStartSwitchOffset = 304;
  static const int apuPercentRpmOffset = 312;

  // Vars for Radio panel
  static const int com1StatusOffset = 320;
  static const int com1TransmitOffset = 328;
  static const int com1FreqOffset = 336;
  static const int com1StandbyOffset = 344;
  static const int nav1FreqOffset = 352;
  static const int nav1StandbyOffset = 360;
  static const int com2StatusOffset = 368;
  static const int com2TransmitOffset = 376;
  static const int com2FreqOffset = 384;
  static const int com2StandbyOffset = 392;
  static const int nav2FreqOffset = 400;
  static const int nav2StandbyOffset = 408;
  static const int com1ReceiveOffset = 416;
  static const int com2ReceiveOffset = 424;
  static const int adfFreqOffset = 432;
  static const int adfStandbyOffset = 440;
  static const int seatBeltsSwitchOffset = 448;
  static const int transponderStateOffset = 456;
  static const int transponderCodeOffset = 464;
  // No vars after here required by Radio panel

  // Vars for Autopilot panel
  static const int altAltitudeOffset = 472;
  static const int asiAirspeedOffset = 480;
  static const int asiMachSpeedOffset = 488;
  static const int hiHeadingOffset = 496;
  static const int vsiVerticalSpeedOffset = 504;
  static const int autopilotAvailableOffset = 512;
  static const int autopilotEngagedOffset = 520;
  static const int flightDirectorActiveOffset = 528;
  static const int autopilotHeadingOffset = 536;
  static const int autopilotHeadingLockOffset = 544;
  static const int autopilotHeadingSlotIndexOffset = 552;
  static const int autopilotLevelOffset = 560;
  static const int autopilotAltitudeOffset = 568;
  static const int autopilotAltitude3Offset = 576;
  static const int autopilotAltLockOffset = 584;
  static const int autopilotPitchHoldOffset = 592;
  static const int autopilotVerticalSpeedOffset = 600;
  static const int autopilotVerticalHoldOffset = 608;
  static const int autopilotVsSlotIndexOffset = 616;
  static const int autopilotAirspeedOffset = 624;
  static const int autopilotMachOffset = 632;
  static const int autopilotAirspeedHoldOffset = 640;
  static const int autopilotApproachHoldOffset = 648;
  static const int autopilotGlideslopeHoldOffset = 656;
  static const int throttlePositionOffset = 664;
  static const int autothrottleActiveOffset = 672;
  // No vars after here required by Autopilot panel

  static const int altKollsmanOffset = 680;
  static const int adiPitchOffset = 688;
  static const int adiBankOffset = 696;
  static const int asiTrueSpeedOffset = 704;
  static const int asiAirspeedCalOffset = 712;
  static const int hiHeadingTrueOffset = 720;
  static const int altAboveGroundOffset = 728;
  static const int tcRateOffset = 736;
  static const int tcBallOffset = 744;
  static const int tfElevatorTrimOffset = 752;
  static const int tfRudderTrimOffset = 760;
  static const int tfSpoilersPositionOffset = 768;
  static const int tfAutoBrakeOffset = 776;
  static const int dcUtcSecondsOffset = 784;
  static const int dcLocalSecondsOffset = 792;
  static const int dcFlightSecondsOffset = 800;
  static const int dcTempCOffset = 808;
  static const int batteryLoadOffset = 816;
  static const int rpmEngineOffset = 824;
  static const int rpmPercentOffset = 832;
  static const int rpmElapsedTimeOffset = 840;
  static const int fuelCapacityOffset = 848;
  static const int fuelQuantityOffset = 856;
  static const int fuelLeftPercentOffset = 864;
  static const int fuelRightPercentOffset = 872;
  static const int vor1ObsOffset = 880;
  static const int vor1RadialErrorOffset = 888;
  static const int vor1GlideSlopeErrorOffset = 896;
  static const int vor1ToFromOffset = 904;
  static const int vor1GlideSlopeFlagOffset = 912;
  static const int vor2ObsOffset = 920;
  static const int vor2RadialErrorOffset = 928;
  static const int vor2ToFromOffset = 936;
  static const int navHasLocalizerOffset = 944;
  static const int navLocalizerOffset = 952;
  static const int gpsDrivesNav1Offset = 960;
  static const int gpsWpCrossTrkOffset = 968;
  static const int adfRadialOffset = 976;
  static const int adfCardOffset = 984;
  static const int gearRetractableOffset = 992;
  static const int gearLeftPosOffset = 1000;
  static const int gearCentrePosOffset = 1008;
  static const int gearRightPosOffset = 1016;
  static const int pushbackStateOffset = 1024;
  static const int rudderPositionOffset = 1032;
  static const int brakePedalOffset = 1040;
  static const int oilTempOffset = 1048;
  static const int oilPressureOffset = 1056;
  static const int exhaustGasTempOffset = 1064;
  static const int engineTypeOffset = 1072;
  static const int engineMaxRpmOffset = 1080;
  static const int turbineEngineN1Offset = 1088;
  static const int propRpmOffset = 1096;
  static const int engineManifoldPressureOffset = 1104;
  static const int engineFuelFlowOffset = 1112;
  static const int suctionPressureOffset = 1120;
  static const int onGroundOffset = 1128;
  static const int gForceOffset = 1136;
  static const int atcTailNumberOffset = 1144;
  static const int atcCallSignOffset = 1176;
  static const int atcFlightNumberOffset = 1208;
  static const int atcHeavyOffset = 1240;
  static const int latitudeOffset = 1248;
  static const int longitudeOffset = 1256;
  static const int landingRateOffset = 1264;
  static const int skytrackStateOffset = 1272;

  double connected = 0;

  // All Jetbridge vars must come first
  double apuMasterSw = 0;
  double jbApuStart = 0;
  double jbApuStartAvail = 0;
  double apuBleed = 0;
  double elecBat1 = 0;
  double elecBat2 = 0;
  double jbFlapsIndex = 0;
  double jbParkBrakePos = 0;
  double jbAutopilot1 = 0;
  double jbAutopilot2 = 0;
  double jbAutothrust = 0;
  double jbAutopilotHeading = 0;
  double jbAutopilotVerticalSpeed = 0;
  double jbAutopilotFpa = 0;
  double jbManagedSpeed = 0;
  double jbManagedHeading = 0;
  double jbManagedAltitude = 0;
  double jbLateralMode = 0;
  double jbVerticalMode = 0;
  double jbLocMode = 0;
  double jbApprMode = 0;
  double jbAutothrustMode = 0;
  double jbAutobrake = 0;
  double jbLeftBrakePedal = 0;
  double jbRightBrakePedal = 0;
  double jbEngineEgt = 0;
  double jbEngineFuelFlow = 0;

  // Vars required for all panels (screensaver, aircraft identification etc.)
  String aircraft = '';
  double cruiseSpeed = 120;
  double dcVolts = 23.7;

  // Vars for Power/Lights panel
  double lightStates = 0;
  double tfFlapsCount = 1;
  double tfFlapsIndex = 0;
  double parkingBrakeOn = 1;
  double apuStartSwitch = 0;
  double apuPercentRpm = 0;

  // Vars for Radio panel
  double com1Status = 0;
  double com1Transmit = 1;
  double com1Freq = 119.225;
  double com1Standby = 124.850;
  double nav1Freq = 110.50;
  double nav1Standby = 113.90;
  double com2Status = 0;
  double com2Transmit = 0;
  double com2Freq = 124.850;
  double com2Standby = 124.850;
  double nav2Freq = 110.50;
  double nav2Standby = 113.90;
  double com1Receive = 1;
  double com2Receive = 1;
  double adfFreq = 394;
  double adfStandby = 368;
  double seatBeltsSwitch = 0;
  double transponderState = 0;
  double transponderCode = 4608;
  // No vars after here required by Radio panel

  // Vars for Autopilot panel
  double altAltitude = 0;
  double asiAirspeed = 0;
  double asiMachSpeed = 0;
  double hiHeading = 0;
  double vsiVerticalSpeed = 0;
  double autopilotAvailable = 1;
  double autopilotEngaged = 0;
  double flightDirectorActive = 0;
  double autopilotHeading = 0;
  double autopilotHeadingLock = 0;
  double autopilotHeadingSlotIndex = 1;
  double autopilotLevel = 0;
  double autopilotAltitude = 0;
  double autopilotAltitude3 = 0;
  double autopilotAltLock = 0;
  double autopilotPitchHold = 0;
  double autopilotVerticalSpeed = 0;
  double autopilotVerticalHold = 0;
  double autopilotVsSlotIndex = 1;
  double autopilotAirspeed = 0;
  double autopilotMach = 0;
  double autopilotAirspeedHold = 0;
  double autopilotApproachHold = 0;
  double autopilotGlideslopeHold = 0;
  double throttlePosition = 0;
  double autothrottleActive = 0;
  // No vars after here required by Autopilot panel

  double altKollsman = 29.92;
  double adiPitch = 0;
  double adiBank = 0;
  double asiTrueSpeed = 0;
  double asiAirspeedCal = -14;
  double hiHeadingTrue = 0;
  double altAboveGround = 0;
  double tcRate = 0;
  double tcBall = 0;
  double tfElevatorTrim = 0;
  double tfRudderTrim = 0;
  double tfSpoilersPosition = 0;
  double tfAutoBrake = 0;
  double dcUtcSeconds = 43200;
  double dcLocalSeconds = 46800;
  double dcFlightSeconds = 0;
  double dcTempC = 26.2;
  double batteryLoad = 0;
  double rpmEngine = 0;
  double rpmPercent = 0;
  double rpmElapsedTime = 0;
  double fuelCapacity = 0;
  double fuelQuantity = 0;
  double fuelLeftPercent = 0;
  double fuelRightPercent = 0;
  double vor1Obs = 0;
  double vor1RadialError = 0;
  double vor1GlideSlopeError = 0;
  double vor1ToFrom = 0;
  double vor1GlideSlopeFlag = 0;
  double vor2Obs = 0;
  double vor2RadialError = 0;
  double vor2ToFrom = 0;
  double navHasLocalizer = 0;
  double navLocalizer = 0;
  double gpsDrivesNav1 = 0;
  double gpsWpCrossTrk = 0;
  double adfRadial = 0;
  double adfCard = 0;
  double gearRetractable = 1;
  double gearLeftPos = 100;
  double gearCentrePos = 100;
  double gearRightPos = 100;
  double pushbackState = 3;
  double rudderPosition = 0;
  double brakePedal = 0;
  double oilTemp = 75;
  double oilPressure = 50;
  double exhaustGasTemp = 0;
  double engineType = 0;
  double engineMaxRpm = 0;
  double turbineEngineN1 = 0;
  double propRpm = 0;
  double engineManifoldPressure = 0;
  double engineFuelFlow = 0;
  double suctionPressure = 1;
  double onGround = 0;
  double gForce = 0;
  String atcTailNumber = '';
  String atcCallSign = '';
  String atcFlightNumber = '';
  double atcHeavy = 0;
  double landingRate = -999;
  double skytrackState = 0;

  double latitude = 0;
  double longitude = 0;

  static MSFSSimVars decode(Uint8List packet) {
    MSFSSimVars simVars = MSFSSimVars();
    simVars.updateFromFullPacket(packet);
    return simVars;
  }

  void updateFromFullPacket(Uint8List packet) {
    ByteData data = ByteData.view(packet.buffer);
    connected = data.getFloat64(connectedOffset, Endian.little);

    // All Jetbridge vars must come first
    apuMasterSw = data.getFloat64(apuMasterSwOffset, Endian.little);
    jbApuStart = data.getFloat64(jbApuStartOffset, Endian.little);
    jbApuStartAvail = data.getFloat64(jbApuStartAvailOffset, Endian.little);
    apuBleed = data.getFloat64(apuBleedOffset, Endian.little);
    elecBat1 = data.getFloat64(elecBat1Offset, Endian.little);
    elecBat2 = data.getFloat64(elecBat2Offset, Endian.little);
    jbFlapsIndex = data.getFloat64(jbFlapsIndexOffset, Endian.little);
    jbParkBrakePos = data.getFloat64(jbParkBrakePosOffset, Endian.little);
    jbAutopilot1 = data.getFloat64(jbAutopilot1Offset, Endian.little);
    jbAutopilot2 = data.getFloat64(jbAutopilot2Offset, Endian.little);
    jbAutothrust = data.getFloat64(jbAutothrustOffset, Endian.little);
    jbAutopilotHeading =
        data.getFloat64(jbAutopilotHeadingOffset, Endian.little);
    jbAutopilotVerticalSpeed =
        data.getFloat64(jbAutopilotVerticalSpeedOffset, Endian.little);
    jbAutopilotFpa = data.getFloat64(jbAutopilotFpaOffset, Endian.little);
    jbManagedSpeed = data.getFloat64(jbManagedSpeedOffset, Endian.little);
    jbManagedHeading = data.getFloat64(jbManagedHeadingOffset, Endian.little);
    jbManagedAltitude = data.getFloat64(jbManagedAltitudeOffset, Endian.little);
    jbLateralMode = data.getFloat64(jbLateralModeOffset, Endian.little);
    jbVerticalMode = data.getFloat64(jbVerticalModeOffset, Endian.little);
    jbLocMode = data.getFloat64(jbLocModeOffset, Endian.little);
    jbApprMode = data.getFloat64(jbApprModeOffset, Endian.little);
    jbAutothrustMode = data.getFloat64(jbAutothrustModeOffset, Endian.little);
    jbAutobrake = data.getFloat64(jbAutobrakeOffset, Endian.little);
    jbLeftBrakePedal = data.getFloat64(jbLeftBrakePedalOffset, Endian.little);
    jbRightBrakePedal = data.getFloat64(jbRightBrakePedalOffset, Endian.little);
    jbEngineEgt = data.getFloat64(jbEngineEgtOffset, Endian.little);
    jbEngineFuelFlow = data.getFloat64(jbEngineFuelFlowOffset, Endian.little);

    // Vars required for all panels (screensaver, aircraft identification etc.)
    aircraft = cStringToDartString(data.buffer.asUint8List(aircraftOffset, 32));
    cruiseSpeed = data.getFloat64(cruiseSpeedOffset, Endian.little);
    dcVolts = data.getFloat64(dcVoltsOffset, Endian.little);

    // Vars for Power/Lights panel
    lightStates = data.getFloat64(lightStatesOffset, Endian.little);
    tfFlapsCount = data.getFloat64(tfFlapsCountOffset, Endian.little);
    tfFlapsIndex = data.getFloat64(tfFlapsIndexOffset, Endian.little);
    parkingBrakeOn = data.getFloat64(parkingBrakeOnOffset, Endian.little);
    apuStartSwitch = data.getFloat64(apuStartSwitchOffset, Endian.little);
    apuPercentRpm = data.getFloat64(apuPercentRpmOffset, Endian.little);

    // Vars for Radio panel
    com1Status = data.getFloat64(com1StatusOffset, Endian.little);
    com1Transmit = data.getFloat64(com1TransmitOffset, Endian.little);
    com1Freq = data.getFloat64(com1FreqOffset, Endian.little);
    com1Standby = data.getFloat64(com1StandbyOffset, Endian.little);
    nav1Freq = data.getFloat64(nav1FreqOffset, Endian.little);
    nav1Standby = data.getFloat64(nav1StandbyOffset, Endian.little);
    com2Status = data.getFloat64(com2StatusOffset, Endian.little);
    com2Transmit = data.getFloat64(com2TransmitOffset, Endian.little);
    com2Freq = data.getFloat64(com2FreqOffset, Endian.little);
    com2Standby = data.getFloat64(com2StandbyOffset, Endian.little);
    nav2Freq = data.getFloat64(nav2FreqOffset, Endian.little);
    nav2Standby = data.getFloat64(nav2StandbyOffset, Endian.little);
    com1Receive = data.getFloat64(com1ReceiveOffset, Endian.little);
    com2Receive = data.getFloat64(com2ReceiveOffset, Endian.little);
    adfFreq = data.getFloat64(adfFreqOffset, Endian.little);
    adfStandby = data.getFloat64(adfStandbyOffset, Endian.little);
    seatBeltsSwitch = data.getFloat64(seatBeltsSwitchOffset, Endian.little);
    transponderState = data.getFloat64(transponderStateOffset, Endian.little);
    transponderCode = data.getFloat64(transponderCodeOffset, Endian.little);
    // No vars after here required by Radio panel

    // Vars for Autopilot panel
    altAltitude = data.getFloat64(altAltitudeOffset, Endian.little);
    asiAirspeed = data.getFloat64(asiAirspeedOffset, Endian.little);
    asiMachSpeed = data.getFloat64(asiMachSpeedOffset, Endian.little);
    hiHeading = data.getFloat64(hiHeadingOffset, Endian.little);
    vsiVerticalSpeed = data.getFloat64(vsiVerticalSpeedOffset, Endian.little);
    autopilotAvailable =
        data.getFloat64(autopilotAvailableOffset, Endian.little);
    autopilotEngaged = data.getFloat64(autopilotEngagedOffset, Endian.little);
    flightDirectorActive =
        data.getFloat64(flightDirectorActiveOffset, Endian.little);
    autopilotHeading = data.getFloat64(autopilotHeadingOffset, Endian.little);
    autopilotHeadingLock =
        data.getFloat64(autopilotHeadingLockOffset, Endian.little);
    autopilotHeadingSlotIndex =
        data.getFloat64(autopilotHeadingSlotIndexOffset, Endian.little);
    autopilotLevel = data.getFloat64(autopilotLevelOffset, Endian.little);
    autopilotAltitude = data.getFloat64(autopilotAltitudeOffset, Endian.little);
    autopilotAltitude3 =
        data.getFloat64(autopilotAltitude3Offset, Endian.little);
    autopilotAltLock = data.getFloat64(autopilotAltLockOffset, Endian.little);
    autopilotPitchHold =
        data.getFloat64(autopilotPitchHoldOffset, Endian.little);
    autopilotVerticalSpeed =
        data.getFloat64(autopilotVerticalSpeedOffset, Endian.little);
    autopilotVerticalHold =
        data.getFloat64(autopilotVerticalHoldOffset, Endian.little);
    autopilotVsSlotIndex =
        data.getFloat64(autopilotVsSlotIndexOffset, Endian.little);
    autopilotAirspeed = data.getFloat64(autopilotAirspeedOffset, Endian.little);
    autopilotMach = data.getFloat64(autopilotMachOffset, Endian.little);
    autopilotAirspeedHold =
        data.getFloat64(autopilotAirspeedHoldOffset, Endian.little);
    autopilotApproachHold =
        data.getFloat64(autopilotApproachHoldOffset, Endian.little);
    autopilotGlideslopeHold =
        data.getFloat64(autopilotGlideslopeHoldOffset, Endian.little);
    throttlePosition = data.getFloat64(throttlePositionOffset, Endian.little);
    autothrottleActive =
        data.getFloat64(autothrottleActiveOffset, Endian.little);
    // No vars after here required by Autopilot panel

    altKollsman = data.getFloat64(altKollsmanOffset, Endian.little);
    adiPitch = data.getFloat64(adiPitchOffset, Endian.little);
    adiBank = data.getFloat64(adiBankOffset, Endian.little);
    asiTrueSpeed = data.getFloat64(asiTrueSpeedOffset, Endian.little);
    asiAirspeedCal = data.getFloat64(asiAirspeedCalOffset, Endian.little);
    hiHeadingTrue = data.getFloat64(hiHeadingTrueOffset, Endian.little);
    altAboveGround = data.getFloat64(altAboveGroundOffset, Endian.little);
    tcRate = data.getFloat64(tcRateOffset, Endian.little);
    tcBall = data.getFloat64(tcBallOffset, Endian.little);
    tfElevatorTrim = data.getFloat64(tfElevatorTrimOffset, Endian.little);
    tfRudderTrim = data.getFloat64(tfRudderTrimOffset, Endian.little);
    tfSpoilersPosition =
        data.getFloat64(tfSpoilersPositionOffset, Endian.little);
    tfAutoBrake = data.getFloat64(tfAutoBrakeOffset, Endian.little);
    dcUtcSeconds = data.getFloat64(dcUtcSecondsOffset, Endian.little);
    dcLocalSeconds = data.getFloat64(dcLocalSecondsOffset, Endian.little);
    dcFlightSeconds = data.getFloat64(dcFlightSecondsOffset, Endian.little);
    dcTempC = data.getFloat64(dcTempCOffset, Endian.little);
    batteryLoad = data.getFloat64(batteryLoadOffset, Endian.little);
    rpmEngine = data.getFloat64(rpmEngineOffset, Endian.little);
    rpmPercent = data.getFloat64(rpmPercentOffset, Endian.little);
    rpmElapsedTime = data.getFloat64(rpmElapsedTimeOffset, Endian.little);
    fuelCapacity = data.getFloat64(fuelCapacityOffset, Endian.little);
    fuelQuantity = data.getFloat64(fuelQuantityOffset, Endian.little);
    fuelLeftPercent = data.getFloat64(fuelLeftPercentOffset, Endian.little);
    fuelRightPercent = data.getFloat64(fuelRightPercentOffset, Endian.little);
    vor1Obs = data.getFloat64(vor1ObsOffset, Endian.little);
    vor1RadialError = data.getFloat64(vor1RadialErrorOffset, Endian.little);
    vor1GlideSlopeError =
        data.getFloat64(vor1GlideSlopeErrorOffset, Endian.little);
    vor1ToFrom = data.getFloat64(vor1ToFromOffset, Endian.little);
    vor1GlideSlopeFlag =
        data.getFloat64(vor1GlideSlopeFlagOffset, Endian.little);
    vor2Obs = data.getFloat64(vor2ObsOffset, Endian.little);
    vor2RadialError = data.getFloat64(vor2RadialErrorOffset, Endian.little);
    vor2ToFrom = data.getFloat64(vor2ToFromOffset, Endian.little);
    navHasLocalizer = data.getFloat64(navHasLocalizerOffset, Endian.little);
    navLocalizer = data.getFloat64(navLocalizerOffset, Endian.little);
    gpsDrivesNav1 = data.getFloat64(gpsDrivesNav1Offset, Endian.little);
    gpsWpCrossTrk = data.getFloat64(gpsWpCrossTrkOffset, Endian.little);
    adfRadial = data.getFloat64(adfRadialOffset, Endian.little);
    adfCard = data.getFloat64(adfCardOffset, Endian.little);
    gearRetractable = data.getFloat64(gearRetractableOffset, Endian.little);
    gearLeftPos = data.getFloat64(gearLeftPosOffset, Endian.little);
    gearCentrePos = data.getFloat64(gearCentrePosOffset, Endian.little);
    gearRightPos = data.getFloat64(gearRightPosOffset, Endian.little);
    pushbackState = data.getFloat64(pushbackStateOffset, Endian.little);
    rudderPosition = data.getFloat64(rudderPositionOffset, Endian.little);
    brakePedal = data.getFloat64(brakePedalOffset, Endian.little);
    oilTemp = data.getFloat64(oilTempOffset, Endian.little);
    oilPressure = data.getFloat64(oilPressureOffset, Endian.little);
    exhaustGasTemp = data.getFloat64(exhaustGasTempOffset, Endian.little);
    engineType = data.getFloat64(engineTypeOffset, Endian.little);
    engineMaxRpm = data.getFloat64(engineMaxRpmOffset, Endian.little);
    turbineEngineN1 = data.getFloat64(turbineEngineN1Offset, Endian.little);
    propRpm = data.getFloat64(propRpmOffset, Endian.little);
    engineManifoldPressure =
        data.getFloat64(engineManifoldPressureOffset, Endian.little);
    engineFuelFlow = data.getFloat64(engineFuelFlowOffset, Endian.little);
    suctionPressure = data.getFloat64(suctionPressureOffset, Endian.little);
    onGround = data.getFloat64(onGroundOffset, Endian.little);
    gForce = data.getFloat64(gForceOffset, Endian.little);
    atcTailNumber =
        cStringToDartString(data.buffer.asUint8List(atcTailNumberOffset, 32));
    atcCallSign =
        cStringToDartString(data.buffer.asUint8List(atcCallSignOffset, 32));
    atcFlightNumber =
        cStringToDartString(data.buffer.asUint8List(atcFlightNumberOffset, 32));
    atcHeavy = data.getFloat64(atcHeavyOffset, Endian.little);
    latitude = data.getFloat64(latitudeOffset, Endian.little);
    longitude = data.getFloat64(longitudeOffset, Endian.little);
    landingRate = data.getFloat64(landingRateOffset, Endian.little);
    skytrackState = data.getFloat64(skytrackStateOffset, Endian.little);
  }

  void updateFromDelta(Uint8List packet) {
    ByteData data = ByteData.view(packet.buffer);
    int i = 0;
    while (i < packet.length) {
      int offset = data.getUint32(i, Endian.little);
      i += 8;
      if (offset >= stringOffset) {
        offset -= stringOffset;
        String value = cStringToDartString(data.buffer.asUint8List(i, 32));
        i += 32;
        switch (offset) {
          case aircraftOffset:
            aircraft = value;
            break;
          case atcTailNumberOffset:
            atcFlightNumber = value;
            break;
          case atcCallSignOffset:
            atcCallSign = value;
            break;
          case atcFlightNumberOffset:
            atcFlightNumber = value;
            break;
        }
      } else {
        double value = data.getFloat64(i, Endian.little);
        i += 8;
        switch (offset) {
          case connectedOffset:
            connected = value;
            break;

          // All Jetbridge vars must come first
          case apuMasterSwOffset:
            apuMasterSw = value;
            break;
          case jbApuStartOffset:
            jbApuStart = value;
            break;
          case jbApuStartAvailOffset:
            jbApuStartAvail = value;
            break;
          case apuBleedOffset:
            apuBleed = value;
            break;
          case elecBat1Offset:
            elecBat1 = value;
            break;
          case elecBat2Offset:
            elecBat2 = value;
            break;
          case jbFlapsIndexOffset:
            jbFlapsIndex = value;
            break;
          case jbParkBrakePosOffset:
            jbParkBrakePos = value;
            break;
          case jbAutopilot1Offset:
            jbAutopilot1 = value;
            break;
          case jbAutopilot2Offset:
            jbAutopilot2 = value;
            break;
          case jbAutothrustOffset:
            jbAutothrust = value;
            break;
          case jbAutopilotHeadingOffset:
            jbAutopilotHeading = value;
            break;
          case jbAutopilotVerticalSpeedOffset:
            jbAutopilotVerticalSpeed = value;
            break;
          case jbAutopilotFpaOffset:
            jbAutopilotFpa = value;
            break;
          case jbManagedSpeedOffset:
            jbManagedSpeed = value;
            break;
          case jbManagedHeadingOffset:
            jbManagedHeading = value;
            break;
          case jbManagedAltitudeOffset:
            jbManagedAltitude = value;
            break;
          case jbLateralModeOffset:
            jbLateralMode = value;
            break;
          case jbVerticalModeOffset:
            jbVerticalMode = value;
            break;
          case jbLocModeOffset:
            jbLocMode = value;
            break;
          case jbApprModeOffset:
            jbApprMode = value;
            break;
          case jbAutothrustModeOffset:
            jbAutothrustMode = value;
            break;
          case jbAutobrakeOffset:
            jbAutobrake = value;
            break;
          case jbLeftBrakePedalOffset:
            jbLeftBrakePedal = value;
            break;
          case jbRightBrakePedalOffset:
            jbRightBrakePedal = value;
            break;
          case jbEngineEgtOffset:
            jbEngineEgt = value;
            break;
          case jbEngineFuelFlowOffset:
            jbEngineFuelFlow = value;
            break;

          // Vars required for all panels (screensaver, aircraft identification etc.)
          case cruiseSpeedOffset:
            cruiseSpeed = value;
            break;
          case dcVoltsOffset:
            dcVolts = value;
            break;

          // Vars for Power/Lights panel
          case lightStatesOffset:
            lightStates = value;
            break;
          case tfFlapsCountOffset:
            tfFlapsCount = value;
            break;
          case tfFlapsIndexOffset:
            tfFlapsIndex = value;
            break;
          case parkingBrakeOnOffset:
            parkingBrakeOn = value;
            break;
          case apuStartSwitchOffset:
            apuStartSwitch = value;
            break;
          case apuPercentRpmOffset:
            apuPercentRpm = value;
            break;

          // Vars for Radio panel
          case com1StatusOffset:
            com1Status = value;
            break;
          case com1TransmitOffset:
            com1Transmit = value;
            break;
          case com1FreqOffset:
            com1Freq = value;
            break;
          case com1StandbyOffset:
            com1Standby = value;
            break;
          case nav1FreqOffset:
            nav1Freq = value;
            break;
          case nav1StandbyOffset:
            nav1Standby = value;
            break;
          case com2StatusOffset:
            com2Status = value;
            break;
          case com2TransmitOffset:
            com2Transmit = value;
            break;
          case com2FreqOffset:
            com2Freq = value;
            break;
          case com2StandbyOffset:
            com2Standby = value;
            break;
          case nav2FreqOffset:
            nav2Freq = value;
            break;
          case nav2StandbyOffset:
            nav2Standby = value;
            break;
          case adfFreqOffset:
            adfFreq = value;
            break;
          case adfStandbyOffset:
            adfStandby = value;
            break;
          case seatBeltsSwitchOffset:
            seatBeltsSwitch = value;
            break;
          case transponderStateOffset:
            transponderState = value;
            break;
          case transponderCodeOffset:
            transponderCode = value;
            break;
          // No vars after here required by Radio panel

          // Vars for Autopilot panel
          case altAltitudeOffset:
            altAltitude = value;
            break;
          case asiAirspeedOffset:
            asiAirspeed = value;
            break;
          case asiMachSpeedOffset:
            asiMachSpeed = value;
            break;
          case hiHeadingOffset:
            hiHeading = value;
            break;
          case vsiVerticalSpeedOffset:
            vsiVerticalSpeed = value;
            break;
          case autopilotAvailableOffset:
            autopilotAvailable = value;
            break;
          case autopilotEngagedOffset:
            autopilotEngaged = value;
            break;
          case flightDirectorActiveOffset:
            flightDirectorActive = value;
            break;
          case autopilotHeadingOffset:
            autopilotHeading = value;
            break;
          case autopilotHeadingLockOffset:
            autopilotHeadingLock = value;
            break;
          case autopilotHeadingSlotIndexOffset:
            autopilotHeadingSlotIndex = value;
            break;
          case autopilotLevelOffset:
            autopilotLevel = value;
            break;
          case autopilotAltitudeOffset:
            autopilotAltitude = value;
            break;
          case autopilotAltitude3Offset:
            autopilotAltitude3 = value;
            break;
          case autopilotAltLockOffset:
            autopilotAltLock = value;
            break;
          case autopilotPitchHoldOffset:
            autopilotPitchHold = value;
            break;
          case autopilotVerticalSpeedOffset:
            autopilotVerticalSpeed = value;
            break;
          case autopilotVerticalHoldOffset:
            autopilotVerticalHold = value;
            break;
          case autopilotVsSlotIndexOffset:
            autopilotVsSlotIndex = value;
            break;
          case autopilotAirspeedOffset:
            autopilotAirspeed = value;
            break;
          case autopilotMachOffset:
            autopilotMach = value;
            break;
          case autopilotAirspeedHoldOffset:
            autopilotAirspeedHold = value;
            break;
          case autopilotApproachHoldOffset:
            autopilotApproachHold = value;
            break;
          case autopilotGlideslopeHoldOffset:
            autopilotGlideslopeHold = value;
            break;
          case throttlePositionOffset:
            throttlePosition = value;
            break;
          case autothrottleActiveOffset:
            autothrottleActive = value;
            break;
          // No vars after here required by Autopilot panel

          case altKollsmanOffset:
            altKollsman = value;
            break;
          case adiPitchOffset:
            adiPitch = value;
            break;
          case adiBankOffset:
            adiBank = value;
            break;
          case asiTrueSpeedOffset:
            asiTrueSpeed = value;
            break;
          case asiAirspeedCalOffset:
            asiAirspeedCal = value;
            break;
          case hiHeadingTrueOffset:
            hiHeadingTrue = value;
            break;
          case altAboveGroundOffset:
            altAboveGround = value;
            break;
          case tcRateOffset:
            tcRate = value;
            break;
          case tcBallOffset:
            tcBall = value;
            break;
          case tfElevatorTrimOffset:
            tfElevatorTrim = value;
            break;
          case tfRudderTrimOffset:
            tfRudderTrim = value;
            break;
          case tfSpoilersPositionOffset:
            tfSpoilersPosition = value;
            break;
          case tfAutoBrakeOffset:
            tfAutoBrake = value;
            break;
          case dcUtcSecondsOffset:
            dcUtcSeconds = value;
            break;
          case dcLocalSecondsOffset:
            dcLocalSeconds = value;
            break;
          case dcFlightSecondsOffset:
            dcFlightSeconds = value;
            break;
          case dcTempCOffset:
            dcTempC = value;
            break;
          case batteryLoadOffset:
            batteryLoad = value;
            break;
          case rpmEngineOffset:
            rpmEngine = value;
            break;
          case rpmPercentOffset:
            rpmPercent = value;
            break;
          case rpmElapsedTimeOffset:
            rpmElapsedTime = value;
            break;
          case fuelCapacityOffset:
            fuelCapacity = value;
            break;
          case fuelQuantityOffset:
            fuelQuantity = value;
            break;
          case fuelLeftPercentOffset:
            fuelLeftPercent = value;
            break;
          case fuelRightPercentOffset:
            fuelRightPercent = value;
            break;
          case vor1ObsOffset:
            vor1Obs = value;
            break;
          case vor1RadialErrorOffset:
            vor1RadialError = value;
            break;
          case vor1GlideSlopeErrorOffset:
            vor1GlideSlopeError = value;
            break;
          case vor1ToFromOffset:
            vor1ToFrom = value;
            break;
          case vor1GlideSlopeFlagOffset:
            vor1GlideSlopeFlag = value;
            break;
          case vor2ObsOffset:
            vor2Obs = value;
            break;
          case vor2RadialErrorOffset:
            vor2RadialError = value;
            break;
          case vor2ToFromOffset:
            vor2ToFrom = value;
            break;
          case navHasLocalizerOffset:
            navHasLocalizer = value;
            break;
          case navLocalizerOffset:
            navLocalizer = value;
            break;
          case gpsDrivesNav1Offset:
            gpsDrivesNav1 = value;
            break;
          case gpsWpCrossTrkOffset:
            gpsWpCrossTrk = value;
            break;
          case adfRadialOffset:
            adfRadial = value;
            break;
          case adfCardOffset:
            adfCard = value;
            break;
          case gearRetractableOffset:
            gearRetractable = value;
            break;
          case gearLeftPosOffset:
            gearLeftPos = value;
            break;
          case gearCentrePosOffset:
            gearCentrePos = value;
            break;
          case gearRightPosOffset:
            gearRightPos = value;
            break;
          case pushbackStateOffset:
            pushbackState = value;
            break;
          case rudderPositionOffset:
            rudderPosition = value;
            break;
          case brakePedalOffset:
            brakePedal = value;
            break;
          case oilTempOffset:
            oilTemp = value;
            break;
          case oilPressureOffset:
            oilPressure = value;
            break;
          case exhaustGasTempOffset:
            exhaustGasTemp = value;
            break;
          case engineTypeOffset:
            engineType = value;
            break;
          case engineMaxRpmOffset:
            engineMaxRpm = value;
            break;
          case turbineEngineN1Offset:
            turbineEngineN1 = value;
            break;
          case propRpmOffset:
            propRpm = value;
            break;
          case engineManifoldPressureOffset:
            engineManifoldPressure = value;
            break;
          case engineFuelFlowOffset:
            engineFuelFlow = value;
            break;
          case suctionPressureOffset:
            suctionPressure = value;
            break;
          case onGroundOffset:
            onGround = value;
            break;
          case gForceOffset:
            gForce = value;
            break;
          case atcHeavyOffset:
            atcHeavy = value;
            break;
          case landingRateOffset:
            landingRate = value;
            break;
          case skytrackStateOffset:
            skytrackState = value;
            break;

          case latitudeOffset:
            latitude = value;
            break;
          case longitudeOffset:
            longitude = value;
            break;
        }
      }
    }
  }

  static int get size => 1280;
}

class MSFS2020SourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'MSFS2020';

  BufferedDatagramSocket? socket;
  InternetAddress? host;
  int connectPort = 52020; // The port on which to send data
  bool scanning = true;
  DateTime nextScanTime = DateTime(0);
  DateTime lastPoll = DateTime(0);
  String scanHost = '192.168.1';
  Simulator simulator = Simulator.MSFS2020;

  InstrumentState state = InstrumentState(lastResponse: DateTime(0));
  MSFSSimVars simVars = MSFSSimVars();

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
    socket?.close();
    socket = null;
  }

  void sendMessage(Uint8List message) {
    socket!.send(message, host!, connectPort);
  }

  Future<void> scanForMSFS() async {
    int i;
    DateTime now = DateTime.now();
    if (now.isAfter(nextScanTime)) {
      //if (Platform.isIOS) {
      // Recreate the socket for each scan on ios.
      // It begins failing if we get no response.
      //  await recreateSocket();
      //}
      InstrumentDataRequest request = InstrumentDataRequest(
        requestedSize: MSFSSimVars.size,
        wantFullData: true,
      );
      Uint8List requestPacket = request.encode();
      List<String> parts = scanHost.split('.');
      if ((parts.length == 4) && (parts[3] == '0')) {
        String subnet = parts.take(3).join('.');
        Logger.log('MSFS: Polling subnet $subnet.0/24');
        for (i = 1; i < 254; i++) {
          socket!.send(
            requestPacket,
            InternetAddress('$subnet.$i', type: InternetAddressType.IPv4),
            connectPort,
          );
        }
      } else {
        // Ask for time and wait for response
        Logger.log('MSFS: Polling host $scanHost');
        socket!.send(
          requestPacket,
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
        if (response.data.length == MSFSSimVars.size) {
          host = response.address;
          scanning = false;
          Logger.log('MSFS: Got response from ${host!.address}');
          simVars.updateFromFullPacket(response.data);
        }
        response = socket!.receive();
      }
    }
  }

  int msfsProcessMessages() {
    int received = 0;
    Datagram? response;
    response = socket!.receive();
    while (response != null) {
      if (response.data.length == MSFSSimVars.size) {
        simVars.updateFromFullPacket(response.data);
      } else {
        simVars.updateFromDelta(response.data);
      }
      response = socket!.receive();
      received = received + 1;
    }
    state.time = simVars.dcUtcSeconds.toInt();
    state.aircraftRegistration = simVars.atcTailNumber;
    state.aircraftType = simVars.aircraft;
    state.indicatedAirspeed = simVars.asiAirspeed;
    state.variometer = simVars.vsiVerticalSpeed *
        60; // convert from feet per second to feet per minute
    state.slip = -simVars.tcBall;
    state.turn = simVars.tcRate * 30;
    state.angularSpeed = 0.0;
    state.altitude = simVars.altAltitude;
    state.heading = simVars.hiHeading;
    state.trueHeading = simVars.hiHeadingTrue;
    state.roll = simVars.adiBank;
    state.pitch = -simVars.adiPitch;
    state.fuel = simVars.fuelQuantity;
    state.gearDownLights = (state.gearDownLights & ~noseGear) |
        ((simVars.gearCentrePos > 0.99) ? noseGear : 0);
    state.gearUpLights = (state.gearUpLights & ~noseGear) |
        ((simVars.gearCentrePos < 0.01) ? noseGear : 0);
    state.gearDownLights = (state.gearDownLights & ~leftGear) |
        ((simVars.gearLeftPos > 0.99) ? leftGear : 0);
    state.gearUpLights = (state.gearUpLights & ~leftGear) |
        ((simVars.gearLeftPos < 0.01) ? leftGear : 0);
    state.gearDownLights = (state.gearDownLights & ~rightGear) |
        ((simVars.gearRightPos > 0.99) ? rightGear : 0);
    state.gearUpLights = (state.gearUpLights & ~rightGear) |
        ((simVars.gearRightPos < 0.01) ? rightGear : 0);

    state.engines[0] = state.engines[0].copyWith(
      rpm: simVars.rpmEngine,
      manifold: simVars.engineManifoldPressure,
      oilPressure: simVars.oilPressure,
      oilOutTemperature: simVars.oilTemp,
      exhaustGasTemperature: simVars.exhaustGasTemp,
      cylinderTemperature: 0.0,
    );
    state.flaps = simVars.tfFlapsIndex / simVars.tfFlapsCount;
    state.propPitch = 0.0;
    state.aileronTrim = 0.0;
    state.elevatorTrim = simVars.tfElevatorTrim;
    state.rudderTrim = simVars.tfRudderTrim;
    state.latitude = simVars.latitude;
    state.longitude = simVars.longitude;
    return received;
  }

  void msfsPollState() {
    InstrumentDataRequest request = InstrumentDataRequest(
      requestedSize: MSFSSimVars.size,
      wantFullData: false,
    );
    Uint8List requestPacket = request.encode();
    sendMessage(requestPacket);
  }

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    DateTime now = DateTime.now();
    bool gotData = false;
    if (socket == null) return current;
    if (scanning) {
      try {
        await scanForMSFS();
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
      try {
        int received = msfsProcessMessages();
        gotData = received > 0;
        msfsPollState();
      } on OSError catch (e) {
        if (e.errorCode == 9) {
          // Bad file descriptor
          await recreateSocket();
        } else {
          rethrow;
        }
      }
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
  bool get hasAltitudeAboveGround => false;

  @override
  bool get reconnectAfterSleep => true;
}
