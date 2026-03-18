import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class VariometerPainter extends AnalogInstrumentPainter {
  double variometer;

  VariometerPainter({this.variometer = 0.0});

  @override
  void drawInstrument(Canvas canvas) {
    double climb = variometer;
    climb = min(climb, 2000.0);
    climb = max(climb, -2000.0);
    drawImage(canvas, Textures.variometerBase, Offset.zero, srcOver);
    drawImage(canvas, Textures.variometerLabels, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(climb * 170.0 / 2000.0 * pi / 180.0);
    drawImage(canvas, Textures.variometerNeedle, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is VariometerPainter) {
      return (oldDelegate.variometer != variometer);
    } else {
      return true;
    }
  }
}
