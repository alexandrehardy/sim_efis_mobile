import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';

class EmptySourcePlugin extends InstrumentDataSourcePlugin {
  @override
  String name = 'None';

  InstrumentState targetState = InstrumentState(lastResponse: DateTime(0));
  @override
  Future<void> init({
    required String connectTo,
    required int port,
    required Simulator simulator,
  }) async {
    UiStateController.setListenOn('');
  }

  @override
  Future<void> close() async {}

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    return targetState.copyWith(
      lastResponse: DateTime.now(),
      aircraftType: '',
      latitude: -33.9650,
      longitude: 18.6015,
    );
  }

  @override
  bool get active => false;

  @override
  bool get hasAltitudeAboveGround => false;

  @override
  bool get reconnectAfterSleep => false;
}
