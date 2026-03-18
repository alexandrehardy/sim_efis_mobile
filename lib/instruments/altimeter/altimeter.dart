import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/altimeter/altimeter_painter.dart';

class Altimeter extends StatelessWidget {
  const Altimeter({
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
            AltimeterPainter(altitude: snapshot.requireData.altitude),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
