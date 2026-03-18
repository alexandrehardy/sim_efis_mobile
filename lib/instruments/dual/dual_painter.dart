import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/analog_instrument_painter.dart';
import 'package:sim_efis/instruments/image.dart';

import 'package:sim_efis/textures.dart';

enum DualType { egt, oil }

class DualGuagePainter extends AnalogInstrumentPainter {
  DualType type;
  EngineState engine;
  AircraftLimits limits;

  DualGuagePainter({
    required this.type,
    required this.engine,
    required this.limits,
  });

  ui.Image? get baseTexture {
    switch (type) {
      case DualType.egt:
        return Textures.dualBase;
      case DualType.oil:
        return Textures.dualBaseOil;
      default:
        return null;
    }
  }

  ui.Image? get labelTexture {
    switch (type) {
      case DualType.egt:
        return Textures.egtChtLabels;
      case DualType.oil:
        return Textures.oilLabels;
      default:
        return null;
    }
  }

  double get maxLeft {
    switch (type) {
      case DualType.egt:
        return limits.exhaustGasTempMax * 1.2;
      case DualType.oil:
        return limits.oilTempMax * 1.2;
      default:
        return limits.exhaustGasTempMax * 1.2;
    }
  }

  double get maxRight {
    switch (type) {
      case DualType.egt:
        return limits.cylinderTempMax * 1.2;
      case DualType.oil:
        return limits.oilPressureMax * 1.2;
      default:
        return limits.exhaustGasTempMax * 1.2;
    }
  }

  double get minLeft {
    switch (type) {
      case DualType.egt:
        return 0.0;
      case DualType.oil:
        return limits.oilTempMin - limits.oilTempMax * 0.2;
      default:
        return limits.exhaustGasTempMax * 1.2;
    }
  }

  double get minRight {
    switch (type) {
      case DualType.egt:
        return 0.0;
      case DualType.oil:
        return limits.oilPressureMin - limits.oilPressureMax * 0.2;
      default:
        return 0.0;
    }
  }

  double get left {
    switch (type) {
      case DualType.egt:
        return engine.exhaustGasTemperature;
      case DualType.oil:
        return engine.oilOutTemperature;
      default:
        return engine.exhaustGasTemperature;
    }
  }

  double get right {
    switch (type) {
      case DualType.egt:
        return engine.cylinderTemperature;
      case DualType.oil:
        return engine.oilPressure;
      default:
        return engine.cylinderTemperature;
    }
  }

  @override
  void drawInstrument(Canvas canvas) {
    double leftDisplay = min(max(left, 0.0), maxLeft);
    double rightDisplay = min(max(right, 0.0), maxRight);
    drawImage(canvas, baseTexture, Offset.zero, srcOver);
    canvas.save();
    canvas.translate(-3.1 / 4.0, 0.0);
    canvas.rotate(
        (135.0 - (leftDisplay - minLeft) / maxLeft * 90.0) / 180.0 * pi);
    drawImage(canvas, Textures.dualNeedle, Offset.zero, srcOver);
    canvas.restore();
    canvas.save();
    canvas.translate(3.1 / 4.0, 0.0);
    canvas.rotate(
        (-135.0 + (rightDisplay - minRight) / maxRight * 90.0) / 180.0 * pi);
    drawImage(canvas, Textures.dualNeedle, Offset.zero, srcOver);
    canvas.restore();
    drawImage(canvas, labelTexture, Offset.zero, srcOver);
  }

  @override
  bool shouldRepaintInstrument(AnalogInstrumentPainter oldDelegate) {
    if (oldDelegate is DualGuagePainter) {
      return (oldDelegate.engine != engine) || (oldDelegate.limits != limits);
    } else {
      return true;
    }
  }
}
