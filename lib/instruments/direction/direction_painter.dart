import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class DirectionPainter extends AnalogInstrumentPainter {
  double heading;

  DirectionPainter({required this.heading});

  @override
  void drawInstrument(Canvas canvas) {
    drawImage(canvas, Textures.directionBase, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(-heading * pi / 180.0);
    drawImage(canvas, Textures.directionCompass, Offset.zero, srcOver);
    canvas.restore();
    drawImage(canvas, Textures.directionCardinal, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is DirectionPainter) {
      return (oldDelegate.heading != heading);
    } else {
      return true;
    }
  }
}
