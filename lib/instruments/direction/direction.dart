import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/direction/direction_painter.dart';

class DirectionIndicator extends StatelessWidget {
  const DirectionIndicator({
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
            DirectionPainter(heading: snapshot.requireData.heading),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
