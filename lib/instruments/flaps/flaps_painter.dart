import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class FlapsPainter extends AnalogInstrumentPainter {
  double flaps;

  FlapsPainter({required this.flaps});

  @override
  void drawInstrument(Canvas canvas) {
    drawImage(canvas, Textures.flapsLabels, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(flaps * 80.0 * pi / 180.0);
    drawImage(canvas, Textures.flapsNeedle, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is FlapsPainter) {
      return (oldDelegate.flaps != flaps);
    } else {
      return true;
    }
  }
}
