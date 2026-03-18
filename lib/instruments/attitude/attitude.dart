import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/attitude/attitude_painter.dart';

class AttitudeIndicator extends StatelessWidget {
  const AttitudeIndicator({
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
        foregroundPainter: AttitudePainter(
          pitch: snapshot.requireData.pitch,
          roll: snapshot.requireData.roll,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
