import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class RpmPainter extends AnalogInstrumentPainter {
  double rpm;
  AircraftLimits limits;

  RpmPainter({
    required this.rpm,
    required this.limits,
  });

  double get minRpm => 0.0;

  double get maxRpm {
    if (limits.maxRpm > 3500.0) {
      return 7000.0;
    }
    return 3500.0;
  }

  ui.Image? get labelTexture {
    if (limits.maxRpm > 3500.0) {
      return Textures.rpmLabels2x;
    }
    return Textures.rpmLabels;
  }

  double rpmToDegrees(double rpm) {
    rpm = max(rpm, minRpm);
    rpm = min(rpm, maxRpm);
    double toDegrees = (360.0 - 108.0) / (maxRpm - minRpm);
    return (rpm - minRpm) * toDegrees - 90.0 - 36.0;
  }

  Offset anglePosition(double angle, double radius) {
    Offset offset = Offset(
      radius * cos((angle - 90.0) * pi / 180.0),
      radius * sin((angle - 90.0) * pi / 180.0),
    );

    if (offset.dx.abs() > offset.dy.abs()) {
      return offset * radius / offset.dx.abs();
    } else {
      return offset * radius / offset.dy.abs();
    }
  }

  List<Offset> getClipPath(double minRpm, double maxRpm) {
    double size = (Textures.rpmBase?.width ?? 512) / 2.0;
    double minAngle = rpmToDegrees(minRpm);
    double maxAngle = rpmToDegrees(maxRpm);
    List<Offset> path = [];
    path.add(const Offset(0.0, 0.0));
    path.add(anglePosition(minAngle, size));
    if ((minAngle < 45.0) && (maxAngle > 45.0)) {
      path.add(Offset(size, -size));
    }
    if ((minAngle < 135.0) && (maxAngle > 135.0)) {
      path.add(Offset(size, size));
    }
    if ((minAngle < 225.0) && (maxAngle > 225.0)) {
      path.add(Offset(-size, size));
    }
    if ((minAngle < 315.0) && (maxAngle > 315.0)) {
      path.add(Offset(-size, -size));
    }
    path.add(anglePosition(maxAngle, size));
    return path;
  }

  void drawArc(
    Canvas canvas, {
    ui.Image? image,
    double minRpm = 0.0,
    double maxRpm = 0.0,
  }) {
    canvas.save();
    canvas.clipPath(Path()..addPolygon(getClipPath(minRpm, maxRpm), true));
    drawImage(canvas, image, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  void drawInstrument(Canvas canvas) {
    double displayedRpm = max(rpm, minRpm);
    displayedRpm = min(displayedRpm, maxRpm);

    drawImage(canvas, Textures.rpmBase, Offset.zero, srcOver);
    drawArc(
      canvas,
      image: Textures.rpmGreenArc,
      minRpm: limits.minRpm,
      maxRpm: limits.maxRpm,
    );

    drawImage(canvas, labelTexture, Offset.zero, srcOver);

    drawArc(
      canvas,
      image: Textures.rpmRedArc,
      minRpm: limits.maxRpm - 40.0,
      maxRpm: limits.maxRpm,
    );

    canvas.rotate(rpmToDegrees(displayedRpm) * pi / 180.0);
    drawImage(canvas, Textures.rpmNeedle, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is RpmPainter) {
      return (oldDelegate.rpm != rpm) || (oldDelegate.limits != limits);
    } else {
      return true;
    }
  }
}
