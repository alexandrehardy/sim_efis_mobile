import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/hud.dart';

class AttitudePainter extends AnalogInstrumentPainter {
  double roll;
  double pitch;

  AttitudePainter({
    required this.pitch,
    required this.roll,
  });

  @override
  void drawInstrument(Canvas canvas) {
    double radius = 1.0;
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset.zero,
          radius: radius,
        ),
      ));
    HudHelper.drawHorizon(canvas: canvas, roll: roll, pitch: pitch);
    HudHelper.drawRollBar(canvas: canvas, roll: roll);
    HudHelper.drawPitchLadder(
      canvas: canvas,
      roll: roll,
      pitch: pitch,
      clip: const Rect.fromLTRB(-1.0, -0.6, 1.0, 0.8),
    );
    HudHelper.drawAirplane(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is AttitudePainter) {
      return (oldDelegate.pitch != pitch) || (oldDelegate.roll != roll);
    } else {
      return true;
    }
  }
}
