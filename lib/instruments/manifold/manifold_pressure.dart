import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/manifold/manifold_pressure_painter.dart';

class ManifoldPressureIndicator extends StatelessWidget {
  final int engine;
  const ManifoldPressureIndicator({
    Key? key,
    required this.engine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstrumentState>(
      initialData: InstrumentDataStream.instance.current,
      stream: InstrumentDataStream.instance.stream,
      builder:
          (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) =>
              CustomPaint(
        foregroundPainter: ManifoldPressurePainter(
          manifoldPressure: snapshot.requireData.engines[engine].manifold,
          limits: snapshot.requireData.limits,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
