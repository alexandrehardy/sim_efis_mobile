import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/dual/dual.dart';
import 'package:sim_efis/instruments/dual/dual_painter.dart';
import 'package:sim_efis/instruments/manifold/manifold_pressure.dart';
import 'package:sim_efis/instruments/rpm/rpm.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/square_widget.dart';

class EngineScreen extends StatelessWidget {
  const EngineScreen({Key? key}) : super(key: key);

  Widget singleEngineData() {
    return const Row(children: [
      Expanded(
        child: Column(
          children: [
            Expanded(
              child: SquareWidget(
                child: RpmIndicator(engine: 0),
              ),
            ),
            Expanded(
              child: SquareWidget(
                child: DualGuage(engine: 0, type: DualType.egt),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Expanded(
              child: SquareWidget(
                child: ManifoldPressureIndicator(engine: 0),
              ),
            ),
            Expanded(
              child: SquareWidget(
                child: DualGuage(engine: 0, type: DualType.oil),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget engineData(int numberOfEngines) {
    int i;
    if (numberOfEngines == 1) {
      return singleEngineData();
    }
    List<Widget> engines = [];
    engines.add(const SizedBox(height: 20.0));
    engines.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (i = 0; i < numberOfEngines; i++)
            Expanded(
              child: Center(
                  child: Text('Engine ${i + 1}',
                      style: EfisStyle.settingsTextStyle)),
            )
        ],
      ),
    );
    engines.add(const SizedBox(height: 10.0));
    engines.add(
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (i = 0; i < numberOfEngines; i++)
              Expanded(
                child: SquareWidget(
                  child: RpmIndicator(engine: i),
                ),
              )
          ],
        ),
      ),
    );
    engines.add(
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (i = 0; i < numberOfEngines; i++)
              Expanded(
                child: SquareWidget(
                  child: ManifoldPressureIndicator(engine: i),
                ),
              )
          ],
        ),
      ),
    );
    engines.add(
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (i = 0; i < numberOfEngines; i++)
              Expanded(
                child: SquareWidget(
                  child: DualGuage(engine: i, type: DualType.egt),
                ),
              ),
          ],
        ),
      ),
    );
    engines.add(
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (i = 0; i < numberOfEngines; i++)
              Expanded(
                child: SquareWidget(
                  child: DualGuage(engine: i, type: DualType.oil),
                ),
              ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: engines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstrumentState>(
        initialData: InstrumentDataStream.instance.current,
        stream: InstrumentDataStream.instance.stream,
        builder: (context, snapshot) {
          return engineData(snapshot.requireData.limits.numberOfEngines);
        });
  }
}
