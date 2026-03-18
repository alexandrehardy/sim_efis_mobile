import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class SlipTurnPainter extends AnalogInstrumentPainter {
  double turn;
  double slip;

  SlipTurnPainter({required this.slip, required this.turn});

  @override
  void drawInstrument(Canvas canvas) {
    double indicatedTurn = min(max(turn, -2.0), 2.0);
    double indicatedSlip = min(max(slip * 6.0, -40.0), 40.0);
    double ballSize = (2.25 - 1.5) / 4.0 / 2.0;
    double ballAxis = (-0.5 * (2.25 + 1.5)) / 4.0;
    double slipOffset = -sin(indicatedSlip * pi / 180.0);

    drawImage(canvas, Textures.turnSlipBase, Offset.zero, srcOver);
    drawImage(canvas, Textures.turnSlipLabels, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(indicatedTurn * 15.0 * pi / 180.0);
    drawImage(canvas, Textures.turnSlipPlane, Offset.zero, srcOver);
    canvas.restore();
    drawImage(
      canvas,
      Textures.turnSlipBall,
      Offset(slipOffset, -ballAxis),
      srcOver,
      scale: ballSize,
    );
    drawImage(canvas, Textures.turnSlipCentre, Offset.zero, srcOver);
    drawImage(canvas, Textures.turnSlipToplabels, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is SlipTurnPainter) {
      return (oldDelegate.turn != turn) || (oldDelegate.slip != slip);
    } else {
      return true;
    }
  }
}
