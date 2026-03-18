import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/flaps/flaps_painter.dart';

class FlapsIndicator extends StatelessWidget {
  const FlapsIndicator({
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
        foregroundPainter: FlapsPainter(flaps: snapshot.requireData.flaps),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
