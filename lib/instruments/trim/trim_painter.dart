import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';
import 'package:sim_efis/settings.dart';

import 'package:sim_efis/textures.dart';

class TrimPainter extends AnalogInstrumentPainter {
  double elevatorTrim;
  double aileronTrim;
  double rudderTrim;

  TrimPainter({
    required this.elevatorTrim,
    required this.aileronTrim,
    required this.rudderTrim,
  });

  @override
  void drawInstrument(Canvas canvas) {
    Paint linePaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 1.0)
      ..strokeWidth = 6.0 / 256.0
      ..filterQuality = Settings.filterQuality;

    drawImage(canvas, Textures.trimLabels, Offset.zero, srcOver);
    canvas.drawPoints(
      ui.PointMode.lines,
      [
        Offset(rudderTrim * 0.25, -3.0 / 4.0),
        Offset(rudderTrim * 0.25, -2.0 / 4.0),
        Offset(-0.5 / 4.0, -elevatorTrim * 0.25 + 2.5 / 4.0),
        Offset(0.5 / 4.0, -elevatorTrim * 0.25 + 2.5 / 4.0),
      ],
      linePaint,
    );
    canvas.save();
    canvas.rotate(aileronTrim * pi / 4.0);
    canvas.drawPoints(
      ui.PointMode.lines,
      const [
        Offset(-2.0 / 4.0, 0.0),
        Offset(2.0 / 4.0, 0.0),
      ],
      linePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is TrimPainter) {
      return (oldDelegate.elevatorTrim != elevatorTrim) ||
          (oldDelegate.aileronTrim != aileronTrim) ||
          (oldDelegate.rudderTrim != rudderTrim);
    } else {
      return true;
    }
  }
}
