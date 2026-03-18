import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/primary/primary_flight_display.dart';

class EfisAttitudeScreen extends StatelessWidget {
  const EfisAttitudeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if ((constraints.maxWidth > constraints.maxHeight)) {
          return const PrimaryFlightDisplay(
            showHeadingTape: true,
            clip: true,
          );
        } else {
          return const PrimaryFlightDisplay(
            showHeadingTape: false,
            showDI: true,
            clip: true,
          );
        }
      },
    );
  }
}
