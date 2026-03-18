import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/image.dart';
import 'package:sim_efis/settings.dart';

import 'package:sim_efis/textures.dart';

abstract class AnalogInstrumentPainter extends CustomPainter {
  TextureState textureState = Textures.state;
  Paint get srcOver => Paint()
    ..color = Colors.white
    ..blendMode = BlendMode.srcOver
    ..filterQuality = Settings.filterQuality;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);
    double caseSize = min(size.width, size.height);
    double instrumentSize = caseSize * 14.0 / 16.0;
    double textureWidth =
        (Textures.instrumentCase?.width ?? caseSize).toDouble();
    double caseScale = caseSize / textureWidth;
    canvas.scale(caseScale);
    canvas.scale(textureWidth / 2.0);
    // Now all coordinates are from -1 to 1
    drawImage(canvas, Textures.instrumentCase, Offset.zero, srcOver);

    canvas.scale(instrumentSize / caseSize);
    drawInstrument(canvas);
    canvas.restore();
  }

  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is AnalogInstrumentPainter) {
      return (oldDelegate.textureState != textureState) ||
          shouldRepaintInstrument(oldDelegate);
    } else {
      return true;
    }
  }

  void drawInstrument(Canvas canvas);
}
