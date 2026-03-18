import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/gear/gear_painter.dart';

class GearIndicator extends StatelessWidget {
  const GearIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: InstrumentDataStream.instance.current,
      stream: InstrumentDataStream.instance.stream,
      builder:
          (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) =>
              CustomPaint(
        foregroundPainter: GearPainter(
          gearUpLights: snapshot.requireData.gearUpLights,
          gearDownLights: snapshot.requireData.gearDownLights,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
