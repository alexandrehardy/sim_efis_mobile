import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/trim/trim_painter.dart';

class TrimIndicator extends StatelessWidget {
  const TrimIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InstrumentState>(
      initialData: InstrumentDataStream.instance.current,
      stream: InstrumentDataStream.instance.stream,
      builder:
          (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) =>
              CustomPaint(
        foregroundPainter: TrimPainter(
          elevatorTrim: snapshot.requireData.elevatorTrim,
          aileronTrim: snapshot.requireData.aileronTrim,
          rudderTrim: snapshot.requireData.rudderTrim,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
