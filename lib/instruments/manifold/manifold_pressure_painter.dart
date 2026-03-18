import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class ManifoldPressurePainter extends AnalogInstrumentPainter {
  double manifoldPressure;
  AircraftLimits limits;

  ManifoldPressurePainter({
    required this.manifoldPressure,
    required this.limits,
  });

  double manifoldPressureToDegrees(double pressure) {
    pressure = max(pressure, 10.0);
    pressure = min(pressure, 50.0);
    double toDegrees = 40.0 / 5.0;
    double angle = (pressure - 30.0) * toDegrees;
    return angle;
  }

  Offset anglePosition(double angle, double radius) {
    Offset offset = Offset(
      radius * cos((-angle - 90.0) * pi / 180.0),
      radius * sin((-angle + 90.0) * pi / 180.0),
    );

    if (offset.dx.abs() > offset.dy.abs()) {
      return offset * radius / offset.dx.abs();
    } else {
      return offset * radius / offset.dy.abs();
    }
  }

  List<Offset> getClipPath(double minPressure, double maxPressure) {
    double size = (Textures.manifoldPressureBase?.width ?? 512) / 2.0;
    double minAngle = manifoldPressureToDegrees(minPressure) + 180.0;
    double maxAngle = manifoldPressureToDegrees(maxPressure) + 180.0;
    List<Offset> path = [];
    path.add(const Offset(0.0, 0.0));
    path.add(anglePosition(minAngle, size));
    if ((minAngle < 45.0) && (maxAngle > 45.0)) {
      path.add(Offset(-size, size));
    }
    if ((minAngle < 135.0) && (maxAngle > 135.0)) {
      path.add(Offset(-size, -size));
    }
    if ((minAngle < 225.0) && (maxAngle > 225.0)) {
      path.add(Offset(size, -size));
    }
    if ((minAngle < 315.0) && (maxAngle > 315.0)) {
      path.add(Offset(size, size));
    }
    path.add(anglePosition(maxAngle, size));
    return path;
  }

  void drawArc(
    Canvas canvas, {
    ui.Image? image,
    double minPressure = 0.0,
    double maxPressure = 0.0,
  }) {
    canvas.save();
    canvas.clipPath(
        Path()..addPolygon(getClipPath(minPressure, maxPressure), true));
    drawImage(canvas, image, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  void drawInstrument(Canvas canvas) {
    double scale = 1.0;

    if (limits.manifoldPressureMax > 50.0) {
      scale = 0.5;
    } else {
      scale = 1.0;
    }
    double displayedPressure = max(manifoldPressure * scale, 10.0);
    displayedPressure = min(displayedPressure, 50.0);

    drawImage(canvas, Textures.manifoldPressureBase, Offset.zero, srcOver);
    drawArc(
      canvas,
      image: Textures.manifoldPressureGreenArc,
      minPressure: limits.manifoldPressureMin * scale,
      maxPressure: limits.manifoldPressureMax * scale,
    );

    if (limits.manifoldPressureMax > 50.0) {
      drawImage(
          canvas, Textures.manifoldPressureLabels2x, Offset.zero, srcOver);
    } else {
      drawImage(canvas, Textures.manifoldPressureLabels, Offset.zero, srcOver);
    }

    drawArc(
      canvas,
      image: Textures.manifoldPressureRedArc,
      minPressure: limits.manifoldPressureMax * scale - 0.5,
      maxPressure: limits.manifoldPressureMax * scale,
    );

    canvas.rotate(manifoldPressureToDegrees(displayedPressure) * pi / 180.0);
    drawImage(canvas, Textures.manifoldPressureNeedle, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is ManifoldPressurePainter) {
      return (oldDelegate.manifoldPressure != manifoldPressure) ||
          (oldDelegate.limits != limits);
    } else {
      return true;
    }
  }
}
