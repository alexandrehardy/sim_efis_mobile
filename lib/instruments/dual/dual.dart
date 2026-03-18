import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/dual/dual_painter.dart';

class DualGuage extends StatelessWidget {
  final int engine;
  final DualType type;
  const DualGuage({
    Key? key,
    required this.engine,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstrumentState>(
      initialData: InstrumentDataStream.instance.current,
      stream: InstrumentDataStream.instance.stream,
      builder:
          (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) =>
              CustomPaint(
        foregroundPainter: DualGuagePainter(
          type: type,
          engine: snapshot.requireData.engines[engine],
          limits: snapshot.requireData.limits,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
