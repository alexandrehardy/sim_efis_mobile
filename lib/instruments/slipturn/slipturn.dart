import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/slipturn/slipturn_painter.dart';

class SlipTurnIndicator extends StatelessWidget {
  const SlipTurnIndicator({
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
        foregroundPainter: SlipTurnPainter(
          slip: snapshot.requireData.slip,
          turn: snapshot.requireData.turn,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
