import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/efis_instrument_painter.dart';
import 'package:sim_efis/instruments/hud.dart';

class PrimaryFlightDisplayPainter extends EfisInstrumentPainter {
  InstrumentState state;
  bool showHeadingTape;
  bool showDI;
  int headingBug;
  int altitudeBug;

  PrimaryFlightDisplayPainter({
    required this.state,
    required this.showHeadingTape,
    required this.showDI,
    required this.headingBug,
    required this.altitudeBug,
    bool clip = false,
  }) : super(clip: clip);

  @override
  void drawInstrument(Canvas canvas) {
    canvas.save();
    if (showDI) {
      canvas.translate(0.0, -0.5);
      canvas.scale(0.7);
    } else {
      double aspect = currentSize.width / currentSize.height;
      if ((0.8 < aspect) && (aspect < 1.2)) {
        // Nearly square, make space for buttons.
        canvas.scale(0.8);
      }
    }
    HudHelper.drawHorizon(canvas: canvas, roll: state.roll, pitch: state.pitch);
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(-0.5, -1.0, 0.5, 1.0));
    if (showHeadingTape) {
      HudHelper.drawHeadingTape(
        canvas: canvas,
        heading: state.heading,
        headingBug: headingBug,
      );
    } else {
      HudHelper.drawRollBar(
          canvas: canvas,
          roll: state.roll,
          clip: const Rect.fromLTRB(-0.8, -1.0, 0.8, 1.0));
    }
    HudHelper.drawPitchLadder(
      canvas: canvas,
      roll: state.roll,
      pitch: state.pitch,
      clip: const Rect.fromLTRB(-1.0, -0.6, 1.0, 0.8),
    );
    canvas.restore();
    HudHelper.drawAirplane(canvas);
    HudHelper.drawGear(
      canvas: canvas,
      gearDownLights: state.gearDownLights,
      gearUpLights: state.gearUpLights,
    );
    HudHelper.drawAirspeedTape(canvas: canvas, state: state);
    HudHelper.drawAltitudeTape(
      canvas: canvas,
      altitude: state.altitude,
      altitudeBug: altitudeBug,
    );
    if (!showDI) {
      HudHelper.drawTapeFlaps(canvas: canvas, flaps: state.flaps);
    }
    if (showHeadingTape) {
      HudHelper.drawHeadingBugSetting(canvas: canvas, heading: headingBug);
    }
    canvas.restore();
    if (showDI) {
      canvas.save();
      canvas.translate(0.0, 0.6);
      canvas.scale(0.3);
      HudHelper.drawDirectionIndicator(
        canvas: canvas,
        heading: state.heading,
        headingBug: headingBug,
      );
      HudHelper.drawElevatorTrim(canvas: canvas, trim: state.elevatorTrim);
      HudHelper.drawRudderTrim(canvas: canvas, trim: state.rudderTrim);
      HudHelper.drawAileronTrim(canvas: canvas, trim: state.aileronTrim);
      HudHelper.drawFlaps(canvas: canvas, flaps: state.flaps);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaintInstrument(EfisInstrumentPainter oldDelegate) {
    if (oldDelegate is PrimaryFlightDisplayPainter) {
      return (oldDelegate.state != state) ||
          (oldDelegate.showHeadingTape != showHeadingTape) ||
          (oldDelegate.showDI != showDI) ||
          (oldDelegate.altitudeBug != altitudeBug) ||
          (oldDelegate.headingBug != headingBug);
    } else {
      return true;
    }
  }
}
