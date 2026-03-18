import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class GearPainter extends AnalogInstrumentPainter {
  int gearUpLights;
  int gearDownLights;

  GearPainter({
    required this.gearUpLights,
    required this.gearDownLights,
  });

  @override
  void drawInstrument(Canvas canvas) {
    double leftX = -1.5 / 4.0;
    double leftY = 0.5 / 4.0;
    double rightX = 1.5 / 4.0;
    double rightY = 0.5 / 4.0;
    double noseX = 0.0;
    double noseY = -1.5 / 4.0;
    double lightRadius = (2.25 - 1.5) / 4.0 * 0.75;
    int lightsOn = 0;
    Offset left = Offset(leftX, leftY);
    Offset right = Offset(rightX, rightY);
    Offset nose = Offset(noseX, noseY);

    drawImage(canvas, Textures.gearBase, Offset.zero, srcOver);
    if (gearDownLights & noseGear > 0) {
      drawImage(
        canvas,
        Textures.gearGreen,
        nose,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= noseGear;
    }
    if (gearDownLights & leftGear > 0) {
      drawImage(
        canvas,
        Textures.gearGreen,
        left,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= leftGear;
    }
    if (gearDownLights & rightGear > 0) {
      drawImage(
        canvas,
        Textures.gearGreen,
        right,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= rightGear;
    }

    if (gearUpLights & noseGear > 0) {
      drawImage(
        canvas,
        Textures.gearRed,
        nose,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= noseGear;
    }
    if (gearUpLights & leftGear > 0) {
      drawImage(
        canvas,
        Textures.gearRed,
        left,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= leftGear;
    }
    if (gearUpLights & rightGear > 0) {
      drawImage(
        canvas,
        Textures.gearRed,
        right,
        srcOver,
        scale: lightRadius,
      );
      lightsOn |= rightGear;
    }

    if (!(lightsOn & noseGear > 0)) {
      drawImage(
        canvas,
        Textures.gearDark,
        nose,
        srcOver,
        scale: lightRadius,
      );
    }
    if (!(lightsOn & leftGear > 0)) {
      drawImage(
        canvas,
        Textures.gearDark,
        left,
        srcOver,
        scale: lightRadius,
      );
    }
    if (!(lightsOn & rightGear > 0)) {
      drawImage(
        canvas,
        Textures.gearDark,
        right,
        srcOver,
        scale: lightRadius,
      );
    }
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is GearPainter) {
      return (oldDelegate.gearUpLights != gearUpLights) ||
          (oldDelegate.gearDownLights != gearDownLights);
    } else {
      return true;
    }
  }
}
