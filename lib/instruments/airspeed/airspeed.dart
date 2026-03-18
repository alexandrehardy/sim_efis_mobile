import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/airspeed/airspeed_painter.dart';

class AirspeedIndicator extends StatelessWidget {
  const AirspeedIndicator({
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
        foregroundPainter: AirspeedPainter(
          airspeed: snapshot.requireData.indicatedAirspeed,
          limits: snapshot.requireData.limits,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
