import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/plugins/sim_efis_active.dart';

class SimEfisDcsUDP extends SimEfisActiveUDP {
  @override
  String get name => 'SimEfisDcsUDP';

  @override
  Future<InstrumentState> poll(InstrumentState current) async {
    InstrumentState newState = await super.poll(current);
    List<EngineState> engines = [];
    for (EngineState engine in newState.engines) {
      EngineState newEngine = engine.copyWith(
        rpm: engine.rpm * state.limits.maxRpm / 100.0,
      );
      engines.add(newEngine);
    }

    return newState.copyWith(
      engines: engines,
    );
  }
}
