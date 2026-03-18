import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

enum TextureState { init, loading, loaded }

class Textures {
  static TextureState state = TextureState.init;
  static Image? aircraft;
  static Image? aircraftSide;
  static Image? airspeedBase;
  static Image? airspeedGreenArc;
  static Image? airspeedLabels;
  static Image? airspeedLabels2x;
  static Image? airspeedLabels3x;
  static Image? airspeedNeedle;
  static Image? airspeedRedArc;
  static Image? airspeedWhiteArc;
  static Image? airspeedYellowArc;
  static Image? altimeterBase;
  static Image? altimeterLabels;
  static Image? altimeterNeedleHundred;
  static Image? altimeterNeedleTenThousand;
  static Image? altimeterNeedleThousand;
  static Image? directionBase;
  static Image? directionCardinal;
  static Image? directionCompass;
  static Image? dualBase;
  static Image? dualBaseOil;
  static Image? dualNeedle;
  static Image? egtChtLabels;
  static Image? flapsLabels;
  static Image? flapsNeedle;
  static Image? gearBase;
  static Image? gearDark;
  static Image? gearGreen;
  static Image? gearRed;
  static Image? horizonBase;
  static Image? hatch;
  static Image? instrumentCase;
  static Image? numbers;
  static Image? oilLabels;
  static Image? rpmBase;
  static Image? rpmGreenArc;
  static Image? rpmRedArc;
  static Image? rpmNeedle;
  static Image? rpmLabels;
  static Image? rpmLabels2x;
  static Image? manifoldPressureBase;
  static Image? manifoldPressureGreenArc;
  static Image? manifoldPressureRedArc;
  static Image? manifoldPressureNeedle;
  static Image? manifoldPressureLabels;
  static Image? manifoldPressureLabels2x;
  static Image? trimBase;
  static Image? trimLabels;
  static Image? turnSlipBall;
  static Image? turnSlipBase;
  static Image? turnSlipLabels;
  static Image? turnSlipPlane;
  static Image? turnSlipCentre;
  static Image? turnSlipToplabels;
  static Image? variometerBase;
  static Image? variometerLabels;
  static Image? variometerNeedle;

  static Future<Image> loadTexture(String assetFileName) async {
    ByteData byteData = await rootBundle.load(assetFileName);
    Uint8List byteList = Uint8List.view(byteData.buffer);
    Codec codec = await instantiateImageCodec(byteList);
    FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<void> loadTextures({VoidCallback? onComplete}) async {
    if (state != TextureState.init) return;
    state = TextureState.loading;
    List<Future<void>> textures = [];
    textures.add(loadTexture('assets/images/aircraft.png').then((image) {
      aircraft = image;
    }));
    textures.add(loadTexture('assets/images/aircraft-side.png').then((image) {
      aircraftSide = image;
    }));
    textures.add(loadTexture('assets/images/airspeed-base.png').then((image) {
      airspeedBase = image;
    }));
    textures
        .add(loadTexture('assets/images/airspeed-greenarc.png').then((image) {
      airspeedGreenArc = image;
    }));
    textures.add(loadTexture('assets/images/airspeed-labels.png').then((image) {
      airspeedLabels = image;
    }));
    textures
        .add(loadTexture('assets/images/airspeed-labels-x2.png').then((image) {
      airspeedLabels2x = image;
    }));
    textures
        .add(loadTexture('assets/images/airspeed-labels-x3.png').then((image) {
      airspeedLabels3x = image;
    }));
    textures.add(loadTexture('assets/images/airspeed-needle.png').then((image) {
      airspeedNeedle = image;
    }));
    textures.add(loadTexture('assets/images/airspeed-redarc.png').then((image) {
      airspeedRedArc = image;
    }));
    textures
        .add(loadTexture('assets/images/airspeed-whitearc.png').then((image) {
      airspeedWhiteArc = image;
    }));
    textures
        .add(loadTexture('assets/images/airspeed-yellowarc.png').then((image) {
      airspeedYellowArc = image;
    }));
    textures.add(loadTexture('assets/images/altimeter-base.png').then((image) {
      altimeterBase = image;
    }));
    textures
        .add(loadTexture('assets/images/altimeter-labels.png').then((image) {
      altimeterLabels = image;
    }));
    textures.add(
        loadTexture('assets/images/altimeter-needle-hundred.png').then((image) {
      altimeterNeedleHundred = image;
    }));
    textures.add(loadTexture('assets/images/altimeter-needle-tenthousand.png')
        .then((image) {
      altimeterNeedleTenThousand = image;
    }));
    textures.add(loadTexture('assets/images/altimeter-needle-thousand.png')
        .then((image) {
      altimeterNeedleThousand = image;
    }));
    textures.add(loadTexture('assets/images/direction-base.png').then((image) {
      directionBase = image;
    }));
    textures
        .add(loadTexture('assets/images/direction-cardinal.png').then((image) {
      directionCardinal = image;
    }));
    textures
        .add(loadTexture('assets/images/direction-compass.png').then((image) {
      directionCompass = image;
    }));
    textures.add(loadTexture('assets/images/dual-base.png').then((image) {
      dualBase = image;
    }));
    textures.add(loadTexture('assets/images/dual-base-oil.png').then((image) {
      dualBaseOil = image;
    }));
    textures.add(loadTexture('assets/images/dual-needle.png').then((image) {
      dualNeedle = image;
    }));
    textures.add(loadTexture('assets/images/dual-egt-cht.png').then((image) {
      egtChtLabels = image;
    }));
    textures.add(loadTexture('assets/images/flaps-labels.png').then((image) {
      flapsLabels = image;
    }));
    textures.add(loadTexture('assets/images/flaps-needle.png').then((image) {
      flapsNeedle = image;
    }));
    textures.add(loadTexture('assets/images/gear-base.png').then((image) {
      gearBase = image;
    }));
    textures.add(loadTexture('assets/images/gear-dark.png').then((image) {
      gearDark = image;
    }));
    textures.add(loadTexture('assets/images/gear-green.png').then((image) {
      gearGreen = image;
    }));
    textures.add(loadTexture('assets/images/gear-red.png').then((image) {
      gearRed = image;
    }));
    textures.add(loadTexture('assets/images/horizon-base.png').then((image) {
      horizonBase = image;
    }));
    textures.add(loadTexture('assets/images/hatch.png').then((image) {
      hatch = image;
    }));
    textures.add(loadTexture('assets/images/case.png').then((image) {
      instrumentCase = image;
    }));
    textures.add(loadTexture('assets/images/numbers.png').then((image) {
      numbers = image;
    }));
    textures.add(loadTexture('assets/images/dual-oil-labels.png').then((image) {
      oilLabels = image;
    }));
    textures.add(loadTexture('assets/images/rpm-base.png').then((image) {
      rpmBase = image;
    }));
    textures.add(loadTexture('assets/images/rpm-greenarc.png').then((image) {
      rpmGreenArc = image;
    }));
    textures.add(loadTexture('assets/images/rpm-redarc.png').then((image) {
      rpmRedArc = image;
    }));
    textures.add(loadTexture('assets/images/rpm-needle.png').then((image) {
      rpmNeedle = image;
    }));
    textures.add(loadTexture('assets/images/rpm-labels.png').then((image) {
      rpmLabels = image;
    }));
    textures.add(loadTexture('assets/images/rpm-labels-x2.png').then((image) {
      rpmLabels2x = image;
    }));
    textures.add(loadTexture('assets/images/manifold-base.png').then((image) {
      manifoldPressureBase = image;
    }));
    textures
        .add(loadTexture('assets/images/manifold-greenarc.png').then((image) {
      manifoldPressureGreenArc = image;
    }));
    textures.add(loadTexture('assets/images/manifold-redarc.png').then((image) {
      manifoldPressureRedArc = image;
    }));
    textures.add(loadTexture('assets/images/manifold-needle.png').then((image) {
      manifoldPressureNeedle = image;
    }));
    textures.add(loadTexture('assets/images/manifold-labels.png').then((image) {
      manifoldPressureLabels = image;
    }));
    textures
        .add(loadTexture('assets/images/manifold-labels-x2.png').then((image) {
      manifoldPressureLabels2x = image;
    }));
    textures.add(loadTexture('assets/images/trim-base.png').then((image) {
      trimBase = image;
    }));
    textures.add(loadTexture('assets/images/trim-labels.png').then((image) {
      trimLabels = image;
    }));
    textures.add(loadTexture('assets/images/turnslip-ball.png').then((image) {
      turnSlipBall = image;
    }));
    textures.add(loadTexture('assets/images/turnslip-base.png').then((image) {
      turnSlipBase = image;
    }));
    textures.add(loadTexture('assets/images/turnslip-labels.png').then((image) {
      turnSlipLabels = image;
    }));
    textures.add(loadTexture('assets/images/turnslip-plane.png').then((image) {
      turnSlipPlane = image;
    }));
    textures
        .add(loadTexture('assets/images/turnslip-slipcentre.png').then((image) {
      turnSlipCentre = image;
    }));
    textures
        .add(loadTexture('assets/images/turnslip-toplabels.png').then((image) {
      turnSlipToplabels = image;
    }));
    textures.add(loadTexture('assets/images/variometer-base.png').then((image) {
      variometerBase = image;
    }));
    textures
        .add(loadTexture('assets/images/variometer-labels.png').then((image) {
      variometerLabels = image;
    }));
    textures
        .add(loadTexture('assets/images/variometer-needle.png').then((image) {
      variometerNeedle = image;
    }));
    await Future.wait(textures);
    state = TextureState.loaded;
    if (onComplete != null) {
      onComplete();
    }
  }
}
