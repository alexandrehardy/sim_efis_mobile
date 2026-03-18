import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/settings.dart';

abstract class InstrumentDataSourcePlugin {
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  });
  Future<InstrumentState> poll(InstrumentState current);
  Future<void> close();
  String get name;
  bool get active;
  bool get hasAltitudeAboveGround;
  bool get reconnectAfterSleep;
}
