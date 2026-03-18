import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class AltimeterPainter extends AnalogInstrumentPainter {
  double altitude;

  AltimeterPainter({required this.altitude});

  @override
  void drawInstrument(Canvas canvas) {
    drawImage(canvas, Textures.altimeterBase, Offset.zero, srcOver);
    drawImage(canvas, Textures.altimeterLabels, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(altitude / 100000.0 * 2.0 * pi);
    drawImage(
        canvas, Textures.altimeterNeedleTenThousand, Offset.zero, srcOver);
    canvas.restore();
    canvas.save();
    canvas.rotate(altitude / 10000.0 * 2.0 * pi);
    drawImage(canvas, Textures.altimeterNeedleThousand, Offset.zero, srcOver);
    canvas.restore();
    canvas.save();
    canvas.rotate(altitude / 1000.0 * 2.0 * pi);
    drawImage(canvas, Textures.altimeterNeedleHundred, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is AltimeterPainter) {
      return (oldDelegate.altitude != altitude);
    } else {
      return true;
    }
  }
}
