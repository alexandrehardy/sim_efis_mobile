import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/variometer/variometer_painter.dart';

class Variometer extends StatelessWidget {
  const Variometer({
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
        foregroundPainter:
            VariometerPainter(variometer: snapshot.requireData.variometer),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
