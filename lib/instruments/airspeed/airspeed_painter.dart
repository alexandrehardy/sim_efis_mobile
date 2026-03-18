import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

class AirspeedPainter extends AnalogInstrumentPainter {
  double airspeed;
  AircraftLimits limits;

  AirspeedPainter({
    required this.airspeed,
    required this.limits,
  });

  double get minSpeed {
    if (limits.vne > 400.0) {
      return 30.0 * 3.0;
    }
    if (limits.vne > 200.0) {
      return 30.0 * 2.0;
    }
    return 30.0;
  }

  double get maxSpeed {
    if (limits.vne > 400.0) {
      return 210.0 * 3.0;
    }
    if (limits.vne > 200.0) {
      return 210.0 * 2.0;
    }
    return 210.0;
  }

  ui.Image? get labelTexture {
    if (limits.vne > 400.0) {
      return Textures.airspeedLabels3x;
    }
    if (limits.vne > 200.0) {
      return Textures.airspeedLabels2x;
    }
    return Textures.airspeedLabels;
  }

  double airspeedToDegrees(double airspeed) {
    airspeed = max(airspeed, minSpeed);
    airspeed = min(airspeed, maxSpeed);
    double speedToDegrees = 360.0 / (maxSpeed - minSpeed);
    return (airspeed - minSpeed) * speedToDegrees;
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

  List<Offset> getClipPath(double minAirspeed, double maxAirspeed) {
    double size = (Textures.airspeedBase?.width ?? 512) / 2.0;
    double minAngle = airspeedToDegrees(minAirspeed);
    double maxAngle = airspeedToDegrees(maxAirspeed);
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
    double minAirspeed = 0.0,
    double maxAirspeed = 0.0,
  }) {
    canvas.save();
    canvas.clipPath(
        Path()..addPolygon(getClipPath(minAirspeed, maxAirspeed), true));
    drawImage(canvas, image, Offset.zero, srcOver);
    canvas.restore();
  }

  @override
  void drawInstrument(Canvas canvas) {
    // 0 degree = 30 knots (airspeed is alive at 30 knots)
    double displayedAirspeed = max(airspeed, minSpeed);
    displayedAirspeed = min(displayedAirspeed, maxSpeed);

    drawImage(canvas, Textures.airspeedBase, Offset.zero, srcOver);
    // green arc: turbulent air
    drawArc(
      canvas,
      image: Textures.airspeedGreenArc,
      minAirspeed: limits.vs,
      maxAirspeed: limits.vno,
    );

    // yellow arc: calm air
    drawArc(
      canvas,
      image: Textures.airspeedYellowArc,
      minAirspeed: limits.vno,
      maxAirspeed: limits.vne,
    );

    // white arc: flaps
    drawArc(
      canvas,
      image: Textures.airspeedWhiteArc,
      minAirspeed: limits.vso,
      maxAirspeed: limits.vfe,
    );

    drawImage(canvas, labelTexture, Offset.zero, srcOver);

    // red arc: vne
    drawArc(
      canvas,
      image: Textures.airspeedRedArc,
      minAirspeed: limits.vne,
      maxAirspeed: limits.vne + 1.0,
    );

    canvas.rotate(airspeedToDegrees(displayedAirspeed) * pi / 180.0);
    drawImage(canvas, Textures.airspeedNeedle, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is AirspeedPainter) {
      return (oldDelegate.airspeed != airspeed) ||
          (oldDelegate.limits != limits);
    } else {
      return true;
    }
  }
}
