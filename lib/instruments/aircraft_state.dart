import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/flaps/flaps.dart';
import 'package:sim_efis/instruments/gear/gear.dart';

class AircraftStateInstruments extends StatelessWidget {
  final Color? backgroundColor;
  const AircraftStateInstruments({
    Key? key,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget instruments = Column(
      children: [
        Container(
          height: 20,
        ),
        const SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(child: GearIndicator()),
              Expanded(child: FlapsIndicator()),
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
    if (backgroundColor != null) {
      return Container(
        color: backgroundColor,
        child: instruments,
      );
    } else {
      return instruments;
    }
  }
}
