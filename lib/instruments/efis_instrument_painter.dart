import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/textures.dart';

abstract class EfisInstrumentPainter extends CustomPainter {
  TextureState textureState = Textures.state;
  final bool clip;
  Size currentSize = const Size(0, 0);

  Paint get srcOver => Paint()
    ..color = Colors.white
    ..blendMode = BlendMode.srcOver
    ..filterQuality = Settings.filterQuality;

  EfisInstrumentPainter({this.clip = false});

  void drawImage(
    Canvas canvas,
    ui.Image? image,
    Offset offset,
    Paint paint, {
    double scale = 1.0,
  }) {
    if (image != null) {
      double width = image.width.toDouble();
      double height = image.height.toDouble();
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, width, height),
        Rect.fromLTWH(
          offset.dx - 1.0 * scale,
          offset.dy - 1.0 * scale,
          2.0 * scale,
          2.0 * scale,
        ),
        paint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    currentSize = size;
    canvas.save();
    if (clip) {
      canvas.clipRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    }
    canvas.translate(size.width / 2.0, size.height / 2.0);
    double caseSize = min(size.width, size.height);
    canvas.scale(caseSize / 2.0);
    if (size.height > size.width) {
      double scale = size.height / (size.width * 1.2);
      if (scale < 1.0) {
        canvas.scale(size.height / (size.width * 1.2));
      }
    }
    // Now all coordinates are from -1 to 1
    drawInstrument(canvas);
    canvas.restore();
  }

  bool shouldRepaintInstrument(EfisInstrumentPainter oldDelegate);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is EfisInstrumentPainter) {
      return (oldDelegate.textureState != textureState) ||
          shouldRepaintInstrument(oldDelegate);
    } else {
      return true;
    }
  }

  void drawInstrument(Canvas canvas);
}
