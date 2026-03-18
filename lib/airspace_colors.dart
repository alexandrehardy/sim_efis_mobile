import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';

Color getAirspaceColor(Airspace airspace) {
  Color airspaceColor = Colors.blueAccent;
  switch (airspace.type) {
    case AirspaceType.Prohibited:
      airspaceColor = Colors.red;
      break;
    case AirspaceType.ProtectedArea:
      airspaceColor = Colors.green;
      break;
    case AirspaceType.Restricted:
      airspaceColor = Colors.red;
      break;
    case AirspaceType.Danger:
      airspaceColor = Colors.amber;
      break;
    default:
      airspaceColor = Colors.blueAccent;
      break;
  }
  return airspaceColor;
}
