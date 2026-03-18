import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/instruments/image.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/textures.dart';

const double hudView = 60.0;
const double degreesPerUnit = (hudView / 2.0);
const double unitsPerDegree = 1.0 / degreesPerUnit;

class Digits {
  bool negative = false;
  int count = 0;
  List<int> digits = [];
}

class DigitAtlas {
  List<RSTransform> transforms = [];
  List<Rect> atlasSections = [];
}

Digits computeDigits(int value) {
  Digits result = Digits();
  int index;
  result.negative = (value < 0);
  value = (value < 0) ? -value : value;

  result.count = 1;
  for (index = 0; index < 10; index++) {
    result.digits.add(value % 10);
    value = value ~/ 10;
    if (result.digits[index] != 0) {
      result.count = index + 1;
    }
  }

  return result;
}

class HudHelper {
  static Paint get srcOver => Paint()
    ..color = Colors.white
    ..blendMode = BlendMode.srcOver
    ..filterQuality = Settings.filterQuality;

  static Paint paintWithColor({
    required double r,
    required double g,
    required double b,
  }) {
    return Paint()
      ..color = Color.fromRGBO(
        (r * 255).toInt(),
        (g * 255).toInt(),
        (b * 255).toInt(),
        1.0,
      )
      ..filterQuality = Settings.filterQuality;
  }

  static DigitAtlas getDigitAtlas({
    required Offset offset,
    required double size,
    required int value,
    required int minDigits,
    required TextAlign align,
  }) {
    if (Textures.numbers == null) return DigitAtlas();

    DigitAtlas atlas = DigitAtlas();
    int textureWidth = Textures.numbers!.width;
    int textureHeight = Textures.numbers!.height;
    double aspect = 25.0 / 35.0;
    Digits digits = computeDigits(value);
    double digitWidth = size * aspect;
    int limit = max(digits.count, minDigits);
    double width = limit * digitWidth;
    double textureDigitWidth = 1.0 / 10.0 * textureWidth;
    double height = size;
    double nextX;
    int i;

    // We render the digits from units to tens
    // So order the position in that way.
    if (align == TextAlign.left) {
      nextX = offset.dx + width;
    } else if (align == TextAlign.right) {
      nextX = offset.dx;
    } else {
      // center
      nextX = offset.dx + width / 2.0;
    }

    for (i = 0; i < limit; i++) {
      atlas.atlasSections.add(Rect.fromLTWH(
        digits.digits[i] * textureDigitWidth,
        0.0,
        textureDigitWidth,
        textureHeight.toDouble(),
      ));
      atlas.transforms.add(RSTransform(
        size / textureHeight,
        0.0,
        nextX - digitWidth,
        offset.dy - height / 2.0,
      ));
      nextX -= digitWidth;
    }

    return atlas;
  }

  static void drawNumber({
    required Canvas canvas,
    required Offset offset,
    required double size,
    required int value,
    required int minDigits,
    required TextAlign align,
    Color color = const Color.fromRGBO(255, 255, 255, 1.0),
  }) {
    if (Textures.numbers == null) return;

    DigitAtlas atlas = getDigitAtlas(
      offset: offset,
      size: size,
      value: value,
      minDigits: minDigits,
      align: align,
    );
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..blendMode = BlendMode.srcOver;
    List<Color> colors = atlas.atlasSections.map((e) => color).toList();
    canvas.drawAtlas(
      Textures.numbers!,
      atlas.transforms,
      atlas.atlasSections,
      colors,
      BlendMode.modulate,
      null,
      white,
    );
  }

  static void drawHorizon({
    required Canvas canvas,
    required double roll,
    required double pitch,
  }) {
    Paint sky = paintWithColor(r: 0.0, g: 0.0, b: 1.0);
    Paint ground = paintWithColor(r: 0.8, g: 0.46, b: 0.16);
    Paint horizon = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 3.0 / 256.0;
    pitch = min(pitch, 90.0);
    pitch = max(pitch, -90.0);
    roll = min(roll, 180.0);
    roll = max(roll, -180.0);
    canvas.save();
    canvas.rotate(roll * pi / 180.0);
    canvas.translate(
      0.0,
      pitch * unitsPerDegree,
    );
    canvas.drawRect(
      Rect.fromPoints(
        const Offset(-30.0, -30.0),
        const Offset(30.0, 0.0),
      ),
      sky,
    );
    canvas.drawRect(
      Rect.fromPoints(
        const Offset(-30.0, 30.0),
        const Offset(30.0, 0.0),
      ),
      ground,
    );
    canvas.drawLine(
      const Offset(-30.0, 0.0),
      const Offset(30.0, 0.0),
      horizon,
    );
    canvas.restore();
  }

  static List<Offset> pitchLines = [];
  static void populatePitchLines() {
    double degree;
    if (pitchLines.isNotEmpty) return;
    // 10 degree
    for (degree = 10; degree <= 90; degree += 10) {
      pitchLines.add(Offset(-0.2, degree * unitsPerDegree));
      pitchLines.add(Offset(0.2, degree * unitsPerDegree));
      pitchLines.add(Offset(-0.2, -degree * unitsPerDegree));
      pitchLines.add(Offset(0.2, -degree * unitsPerDegree));
    }
    // 5 degree
    for (degree = 5; degree <= 90; degree += 10) {
      pitchLines.add(Offset(-0.1, degree * unitsPerDegree));
      pitchLines.add(Offset(0.1, degree * unitsPerDegree));
      pitchLines.add(Offset(-0.1, -degree * unitsPerDegree));
      pitchLines.add(Offset(0.1, -degree * unitsPerDegree));
    }
    // 2.5 degree
    for (degree = 2.5; degree <= 90; degree += 5) {
      pitchLines.add(Offset(-0.05, degree * unitsPerDegree));
      pitchLines.add(Offset(0.05, degree * unitsPerDegree));
      pitchLines.add(Offset(-0.05, -degree * unitsPerDegree));
      pitchLines.add(Offset(0.05, -degree * unitsPerDegree));
    }
  }

  static DigitAtlas pitchAtlas = DigitAtlas();

  static void populatePitchAtlas() {
    if (Textures.numbers == null) return;
    if (pitchAtlas.atlasSections.isNotEmpty) return;

    double degree;
    double fontSize = 0.06;
    for (degree = 10; degree <= 90; degree += 10) {
      DigitAtlas atlas = getDigitAtlas(
        offset: Offset(-0.21, degree * unitsPerDegree),
        size: fontSize,
        value: (degree + 0.5).toInt(),
        minDigits: 1,
        align: TextAlign.right,
      );
      pitchAtlas.atlasSections.addAll(atlas.atlasSections);
      pitchAtlas.transforms.addAll(atlas.transforms);

      atlas = getDigitAtlas(
        offset: Offset(0.21, degree * unitsPerDegree),
        size: fontSize,
        value: (degree + 0.5).toInt(),
        minDigits: 1,
        align: TextAlign.left,
      );
      pitchAtlas.atlasSections.addAll(atlas.atlasSections);
      pitchAtlas.transforms.addAll(atlas.transforms);
    }

    for (degree = -10; degree >= -90; degree -= 10) {
      DigitAtlas atlas = getDigitAtlas(
        offset: Offset(-0.21, degree * unitsPerDegree),
        size: fontSize,
        value: (degree - 0.5).toInt(),
        minDigits: 1,
        align: TextAlign.right,
      );
      pitchAtlas.atlasSections.addAll(atlas.atlasSections);
      pitchAtlas.transforms.addAll(atlas.transforms);

      atlas = getDigitAtlas(
        offset: Offset(0.21, degree * unitsPerDegree),
        size: fontSize,
        value: (degree - 0.5).toInt(),
        minDigits: 1,
        align: TextAlign.left,
      );
      pitchAtlas.atlasSections.addAll(atlas.atlasSections);
      pitchAtlas.transforms.addAll(atlas.transforms);
    }
  }

  static void drawPitchLadder({
    required Canvas canvas,
    required double roll,
    required double pitch,
    Rect? clip,
  }) {
    populatePitchLines();
    populatePitchAtlas();
    DigitAtlas labels = pitchAtlas;
    Paint line = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 2.0 / 256.0;
    pitch = min(pitch, 90.0);
    pitch = max(pitch, -90.0);
    roll = min(roll, 180.0);
    roll = max(roll, -180.0);
    canvas.save();
    canvas.rotate(roll * pi / 180.0);
    if (clip != null) {
      canvas.clipRect(clip);
    }
    canvas.translate(
      0.0,
      pitch * unitsPerDegree,
    );

    canvas.drawPoints(PointMode.lines, pitchLines, line);

    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..blendMode = BlendMode.srcOver;
    // Write text for degrees
    if (Textures.numbers != null) {
      canvas.drawAtlas(
        Textures.numbers!,
        labels.transforms,
        labels.atlasSections,
        null,
        null,
        null,
        white,
      );
    }
    canvas.restore();
  }

  static List<Offset> rollBarLines = [
    Offset(0.75 * cos(100.0 * pi / 180.0), -0.75 * sin(100.0 * pi / 180.0)),
    Offset(0.8 * cos(100.0 * pi / 180.0), -0.8 * sin(100.0 * pi / 180.0)),
    Offset(0.75 * cos(110.0 * pi / 180.0), -0.75 * sin(110.0 * pi / 180.0)),
    Offset(0.8 * cos(110.0 * pi / 180.0), -0.8 * sin(110.0 * pi / 180.0)),
    Offset(0.75 * cos(120.0 * pi / 180.0), -0.75 * sin(120.0 * pi / 180.0)),
    Offset(0.85 * cos(120.0 * pi / 180.0), -0.85 * sin(120.0 * pi / 180.0)),
    Offset(0.75 * cos(135.0 * pi / 180.0), -0.75 * sin(135.0 * pi / 180.0)),
    Offset(0.8 * cos(135.0 * pi / 180.0), -0.8 * sin(135.0 * pi / 180.0)),
    Offset(0.75 * cos(150.0 * pi / 180.0), -0.75 * sin(150.0 * pi / 180.0)),
    Offset(0.85 * cos(150.0 * pi / 180.0), -0.85 * sin(150.0 * pi / 180.0)),
    Offset(0.75 * cos(80.0 * pi / 180.0), -0.75 * sin(80.0 * pi / 180.0)),
    Offset(0.8 * cos(80.0 * pi / 180.0), -0.8 * sin(80.0 * pi / 180.0)),
    Offset(0.75 * cos(70.0 * pi / 180.0), -0.75 * sin(70.0 * pi / 180.0)),
    Offset(0.8 * cos(70.0 * pi / 180.0), -0.8 * sin(70.0 * pi / 180.0)),
    Offset(0.75 * cos(60.0 * pi / 180.0), -0.75 * sin(60.0 * pi / 180.0)),
    Offset(0.85 * cos(60.0 * pi / 180.0), -0.85 * sin(60.0 * pi / 180.0)),
    Offset(0.75 * cos(45.0 * pi / 180.0), -0.75 * sin(45.0 * pi / 180.0)),
    Offset(0.8 * cos(45.0 * pi / 180.0), -0.8 * sin(45.0 * pi / 180.0)),
    Offset(0.75 * cos(30.0 * pi / 180.0), -0.75 * sin(30.0 * pi / 180.0)),
    Offset(0.85 * cos(30.0 * pi / 180.0), -0.85 * sin(30.0 * pi / 180.0)),
  ];

  static void drawRollBar({
    required Canvas canvas,
    required double roll,
    Rect? clip,
  }) {
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 2.0 / 256.0;

    canvas.drawVertices(
      Vertices(
        VertexMode.triangles,
        const [
          Offset(-0.05, -0.64),
          Offset(0.05, -0.64),
          Offset(0.0, -0.74),
        ],
      ),
      BlendMode.src,
      white,
    );

    canvas.save();
    if (clip != null) {
      canvas.clipRect(clip);
    }
    canvas.rotate(roll * pi / 180.0);
    canvas.drawVertices(
      Vertices(
        VertexMode.triangles,
        const [
          Offset(-0.05, -0.85),
          Offset(0.05, -0.85),
          Offset(0.0, -0.75),
        ],
      ),
      BlendMode.src,
      white,
    );

    canvas.drawPoints(PointMode.lines, rollBarLines, white);
    canvas.restore();
  }

  static void drawAirplane(Canvas canvas, {double width = 0.5}) {
    Paint plane = paintWithColor(r: 0.8, g: 0.9, b: 0.2)
      ..strokeWidth = 4.0 / 256.0;
    canvas.drawPoints(
        PointMode.lines,
        [
          Offset(-width, 0.0),
          const Offset(-0.1, 0.0),
          const Offset(-0.1, 0.0),
          const Offset(-0.1, 0.05),
          Offset(width, 0.0),
          const Offset(0.1, 0.0),
          const Offset(0.1, 0.0),
          const Offset(0.1, 0.05),
        ],
        plane);

    canvas.drawPoints(PointMode.points, const [Offset(0.0, 0.0)],
        plane..strokeWidth = 6.0 / 256.0);
  }

  static void drawHeadingTape({
    required Canvas canvas,
    required double heading,
    required int headingBug,
  }) {
    // Modify clip planes for tape
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 2.0 / 256.0;
    Paint bugPaint = paintWithColor(r: 0.0, g: 0.75, b: 1.0)
      ..strokeWidth = 8.0 / 256.0;
    while (heading >= 360.0) {
      heading -= 360.0;
    }
    while (heading < 0.0) {
      heading += 360.0;
    }
    int i;
    DigitAtlas labels = DigitAtlas();
    double fontSize = 0.06;
    double horizontal = 0.6 + 0.6;
    int discreteHeading = (heading + 0.5).toInt();
    discreteHeading = discreteHeading - discreteHeading % 10;
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(-0.5, -1.0, 0.5, 1.0));

    for (i = discreteHeading - 20; i <= discreteHeading + 20; i += 10) {
      canvas.drawLine(
        Offset((i - heading) * horizontal / 40.0, -0.8),
        Offset((i - heading) * horizontal / 40.0, -0.85),
        white,
      );
    }
    for (i = discreteHeading - 25; i <= discreteHeading + 25; i += 10) {
      canvas.drawLine(
        Offset((i - heading) * horizontal / 40.0, -0.8),
        Offset((i - heading) * horizontal / 40.0, -0.825),
        white,
      );
    }

    // Bug
    double bugOffset = (headingBug - heading);
    while (bugOffset >= 180.0) {
      bugOffset -= 360.0;
    }
    while (bugOffset < -180.0) {
      bugOffset += 360.0;
    }

    if (bugOffset < -16) bugOffset = -16;
    if (bugOffset > 16) bugOffset = 16;
    bugOffset = bugOffset * horizontal / 40.0;

    canvas.drawPoints(
      PointMode.lines,
      [
        Offset(bugOffset, -0.8),
        Offset(bugOffset, -0.87),
      ],
      bugPaint,
    );

    // Caret
    canvas.drawPoints(
      PointMode.lines,
      [
        const Offset(-0.03, -0.76),
        const Offset(0.0, -0.8),
        const Offset(0.03, -0.76),
        const Offset(0.0, -0.8),
      ],
      white,
    );

    if (Textures.numbers != null) {
      for (i = discreteHeading - 20; i <= discreteHeading + 20; i += 10) {
        DigitAtlas atlas = getDigitAtlas(
          offset: Offset(
              (i - heading) * horizontal / 40.0, -0.875 - fontSize / 2.0),
          size: fontSize,
          value: (i + 360) % 360,
          minDigits: 1,
          align: TextAlign.center,
        );
        labels.atlasSections.addAll(atlas.atlasSections);
        labels.transforms.addAll(atlas.transforms);
      }
      canvas.drawAtlas(
        Textures.numbers!,
        labels.transforms,
        labels.atlasSections,
        null,
        null,
        null,
        white,
      );
    }
    canvas.restore();
  }

  static void drawHeadingBugSetting(
      {required Canvas canvas, required int heading}) {
    // Draw the heading bug direction
    double fontSize = 0.06;
    drawNumber(
      canvas: canvas,
      value: heading.toInt(),
      minDigits: 3,
      size: fontSize,
      align: TextAlign.center,
      offset: const Offset(
        (-0.95 - 0.55) * 0.5,
        -0.89,
      ),
      color: const Color.fromRGBO(0, 192, 255, 1.0),
    );
  }

  static void drawBox({required Canvas canvas, required Rect box}) {
    Paint linePaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 0.5)
      ..strokeWidth = 2.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint fillPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(0, 0, 0, 0.5)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(box.left, box.top),
          Offset(box.right, box.top),
          Offset(box.right, box.bottom),
          Offset(box.left, box.bottom),
        ],
      ),
      BlendMode.srcATop,
      fillPaint,
    );
    canvas.drawPoints(
      PointMode.polygon,
      [
        Offset(box.left, box.top),
        Offset(box.right, box.top),
        Offset(box.right, box.bottom),
        Offset(box.left, box.bottom),
        Offset(box.left, box.top),
      ],
      linePaint,
    );
  }

  static void drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    double scale = 1.0,
    double rotate = 0.0,
    double opacity = 0.75,
  }) {
    double reverseScale = 0.008 * scale;
    canvas.save();
    canvas.scale(reverseScale);
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: Color.fromRGBO(255, 255, 255, opacity),
        fontSize: 12.0,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    canvas.translate(offset.dx / reverseScale, offset.dy / reverseScale);
    canvas.rotate(rotate * pi / 180.0);
    canvas.translate(-tp.width * 0.5, -tp.height * 0.5);
    tp.paint(
      canvas,
      const Offset(0.0, 0.0),
    );
    canvas.restore();
  }

  static void drawAirspeedTape({
    required Canvas canvas,
    required InstrumentState state,
  }) {
    Paint whiteTransparent = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 0.5)
      ..strokeWidth = 2.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 1.0 / 256.0;
    Paint black = paintWithColor(r: 0.0, g: 0.0, b: 0.0);
    Paint red = paintWithColor(r: 0.8, g: 0.0, b: 0.0);
    Paint green = paintWithColor(r: 0.0, g: 0.8, b: 0.0);
    Paint yellow = paintWithColor(r: 0.8, g: 0.8, b: 0.0);

    int i;
    DigitAtlas labels = DigitAtlas();
    double vertical = 0.8 + 0.8;
    double fontSize = 0.06;
    int airspeed = (state.indicatedAirspeed + 0.5).toInt();
    double offset;

    canvas.save();
    drawBox(
      canvas: canvas,
      box: const Rect.fromLTRB(-0.95, -0.8, -0.55, 0.8),
    );
    canvas.clipRect(const Rect.fromLTRB(-0.95, -0.8, -0.55, 0.8));

    // draw the background numbers
    if (Textures.numbers != null) {
      for (i = -5; i <= 5; i++) {
        int speed = airspeed - i * 10;
        if (speed < 0) continue;
        speed = speed - speed % 10;
        offset = speed - state.indicatedAirspeed;
        DigitAtlas atlas = getDigitAtlas(
            offset: Offset(-0.65, -offset * vertical / 100.0),
            size: fontSize,
            value: speed,
            minDigits: 1,
            align: TextAlign.right);
        labels.atlasSections.addAll(atlas.atlasSections);
        labels.transforms.addAll(atlas.transforms);
      }
      canvas.drawAtlas(
        Textures.numbers!,
        labels.transforms,
        labels.atlasSections,
        null,
        null,
        null,
        whiteTransparent,
      );
    }

    // draw the yellow, white, green and red arcs
    // red arc first (everything not covered by the others)
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(-0.60, state.indicatedAirspeed * vertical / 100.0),
          Offset(-0.55, state.indicatedAirspeed * vertical / 100.0),
          Offset(-0.55, (state.indicatedAirspeed - 800) * vertical / 100.0),
          Offset(-0.60, (state.indicatedAirspeed - 800) * vertical / 100.0),
        ],
      ),
      BlendMode.src,
      red,
    );

    // green arc
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vs) * vertical / 100.0),
          Offset(-0.55,
              (state.indicatedAirspeed - state.limits.vs) * vertical / 100.0),
          Offset(-0.55,
              (state.indicatedAirspeed - state.limits.vno) * vertical / 100.0),
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vno) * vertical / 100.0),
        ],
      ),
      BlendMode.src,
      green,
    );

    // yellow arc
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vno) * vertical / 100.0),
          Offset(-0.55,
              (state.indicatedAirspeed - state.limits.vno) * vertical / 100.0),
          Offset(-0.55,
              (state.indicatedAirspeed - state.limits.vne) * vertical / 100.0),
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vne) * vertical / 100.0),
        ],
      ),
      BlendMode.src,
      yellow,
    );

    // white arc
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vso) * vertical / 100.0),
          Offset(-0.575,
              (state.indicatedAirspeed - state.limits.vso) * vertical / 100.0),
          Offset(-0.575,
              (state.indicatedAirspeed - state.limits.vfe) * vertical / 100.0),
          Offset(-0.60,
              (state.indicatedAirspeed - state.limits.vfe) * vertical / 100.0),
        ],
      ),
      BlendMode.src,
      white,
    );

    // link speeds to points on tape
    for (i = -5; i <= 5; i++) {
      int speed = airspeed - i * 10;
      if (speed < 0) continue;
      speed = speed - speed % 10;
      offset = speed - state.indicatedAirspeed;
      canvas.drawLine(
        Offset(-0.63, -offset * vertical / 100.0),
        Offset(-0.55, -offset * vertical / 100.0),
        white,
      );
    }

    // draw secondary tick lines
    for (i = -6; i <= 6; i++) {
      int speed = airspeed - i * 10;
      speed = speed - speed % 10 - 5;
      if (speed < 0) continue;
      offset = speed - state.indicatedAirspeed;
      canvas.drawLine(
        Offset(-0.60, -offset * vertical / 100.0),
        Offset(-0.55, -offset * vertical / 100.0),
        white,
      );
    }

    // draw a box for the actual speed
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        const [
          Offset(-0.575, 0.0),
          Offset(-0.63, -0.05),
          Offset(-0.9, -0.05),
          Offset(-0.9, 0.05),
          Offset(-0.63, 0.05),
        ],
      ),
      BlendMode.src,
      black,
    );
    canvas.drawPoints(
      PointMode.polygon,
      const [
        Offset(-0.575, 0.0),
        Offset(-0.63, -0.05),
        Offset(-0.9, -0.05),
        Offset(-0.9, 0.05),
        Offset(-0.63, 0.05),
        Offset(-0.575, 0.0),
      ],
      white,
    );

    // draw the actual air speed
    drawNumber(
      canvas: canvas,
      offset: const Offset(-0.65, 0.0),
      size: fontSize,
      value: airspeed,
      minDigits: 1,
      align: TextAlign.right,
    );
    canvas.restore();
    drawText(
        canvas: canvas,
        text: 'kt',
        offset: const Offset(
          (-0.95 - 0.55) * 0.5,
          0.89,
        ));
  }

  static void drawAltitudeTape({
    required Canvas canvas,
    required double altitude,
    required int altitudeBug,
  }) {
    canvas.save();
    Paint whiteTransparent = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 0.5)
      ..strokeWidth = 2.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0)
      ..strokeWidth = 1.0 / 256.0;
    Paint altitudeBugPaint = paintWithColor(r: 0.0, g: 0.75, b: 1.0)
      ..strokeWidth = 1.0 / 256.0;
    Paint black = paintWithColor(r: 0.0, g: 0.0, b: 0.0);

    int i;
    DigitAtlas labels = DigitAtlas();
    double vertical = 0.8 + 0.8;
    double fontSize = 0.06;
    int discreteAltitude = (altitude + 0.5).toInt();

    drawBox(
      canvas: canvas,
      box: const Rect.fromLTRB(0.55, -0.8, 0.95, 0.8),
    );

    canvas.clipRect(const Rect.fromLTRB(0.55, -0.8, 0.95, 0.8));
    // draw the background numbers
    if (Textures.numbers != null) {
      for (i = -5; i <= 5; i++) {
        int height = discreteAltitude - i * 100;
        if (height < 0) continue;
        height = height - height % 100;
        double offset = height - altitude;
        DigitAtlas atlas = getDigitAtlas(
            offset: Offset(0.9, -offset * vertical / 1000.0),
            size: fontSize,
            value: height,
            minDigits: 1,
            align: TextAlign.right);
        labels.atlasSections.addAll(atlas.atlasSections);
        labels.transforms.addAll(atlas.transforms);
      }
      canvas.drawAtlas(
        Textures.numbers!,
        labels.transforms,
        labels.atlasSections,
        null,
        null,
        null,
        whiteTransparent,
      );
    }

    // Draw rule lines to the altitudes
    for (i = -5; i <= 5; i++) {
      int height = discreteAltitude - i * 100;
      if (height < 0) continue;
      height = height - height % 100;
      double offset = height - altitude;
      canvas.drawLine(
        Offset(0.55, -offset * vertical / 1000.0),
        Offset(0.65, -offset * vertical / 1000.0),
        white,
      );
    }
    for (i = -6; i <= 6; i++) {
      int height = discreteAltitude - i * 100;
      height = height - height % 100 - 50;
      if (height < 0) continue;
      double offset = height - altitude;
      canvas.drawLine(
        Offset(0.55, -offset * vertical / 1000.0),
        Offset(0.60, -offset * vertical / 1000.0),
        white,
      );
    }

    if (altitudeBug > 0) {
      // draw altitude bug
      double bugOffset = (altitudeBug - altitude);
      if (bugOffset > 500) bugOffset = 500;
      if (bugOffset < -500) bugOffset = -500;
      bugOffset = bugOffset * vertical / 1000.0;
      canvas.drawVertices(
        Vertices(
          VertexMode.triangleStrip,
          [
            Offset(0.63, -0.05 - bugOffset),
            Offset(0.55, -0.05 - bugOffset),
            Offset(0.575, 0.0 - bugOffset),
            Offset(0.55, 0.05 - bugOffset),
            Offset(0.63, 0.05 - bugOffset),
          ],
        ),
        BlendMode.src,
        altitudeBugPaint,
      );
    }

    // draw a box for the actual altitude
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        const [
          Offset(0.575, 0.0),
          Offset(0.63, -0.05),
          Offset(0.9, -0.05),
          Offset(0.9, 0.05),
          Offset(0.63, 0.05),
        ],
      ),
      BlendMode.src,
      black,
    );
    canvas.drawPoints(
      PointMode.polygon,
      const [
        Offset(0.575, 0.0),
        Offset(0.63, -0.05),
        Offset(0.9, -0.05),
        Offset(0.9, 0.05),
        Offset(0.63, 0.05),
        Offset(0.575, 0.0),
      ],
      white,
    );

    // draw the actual altitude
    drawNumber(
      canvas: canvas,
      offset: const Offset(0.89, 0.0),
      size: fontSize,
      value: discreteAltitude,
      minDigits: 1,
      align: TextAlign.right,
    );

    canvas.restore();

    drawText(
      canvas: canvas,
      text: 'ft',
      offset: const Offset(
        (0.95 + 0.55) * 0.5,
        0.89,
      ),
    );

    if (altitudeBug > 0) {
      drawNumber(
        size: 0.06,
        canvas: canvas,
        value: altitudeBug,
        align: TextAlign.left,
        minDigits: 0,
        offset: const Offset(
          (0.95 + 0.5) * 0.5,
          -0.89,
        ),
        color: const Color.fromRGBO(0, 192, 255, 1.0),
      );
    }
  }

  static void drawDirectionIndicator({
    required Canvas canvas,
    required double heading,
    required int headingBug,
  }) {
    Paint bugPaint = paintWithColor(r: 0.0, g: 0.75, b: 1.0)
      ..strokeWidth = 1.0 / 256.0;
    double fontSize = 0.16;
    drawImage(canvas, Textures.directionBase, Offset.zero, srcOver);
    canvas.save();
    canvas.rotate(-heading * pi / 180.0);
    drawImage(canvas, Textures.directionCompass, Offset.zero, srcOver);
    canvas.restore();
    drawImage(canvas, Textures.directionCardinal, Offset.zero, srcOver);
    canvas.save();

    canvas.rotate(-(heading - headingBug) * pi / 180.0);
    // Draw the bug
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleStrip,
        const [
          Offset(-0.08, -1.0),
          Offset(-0.08, -0.9),
          Offset(-0.05, -1.0),
          Offset(-0.05, -0.9),
          Offset(0.0, -0.92),
          Offset(0.05, -0.9),
          Offset(0.05, -1.0),
          Offset(0.08, -0.9),
          Offset(0.08, -1.0),
        ],
      ),
      BlendMode.src,
      bugPaint,
    );
    canvas.restore();

    drawBox(
      canvas: canvas,
      box: const Rect.fromLTRB(-0.25, -1.325, 0.25, -1.075),
    );
    drawNumber(
      canvas: canvas,
      offset: const Offset(0.0, -1.2),
      size: fontSize,
      value: heading.toInt(),
      minDigits: 3,
      align: TextAlign.center,
    );

    // Draw bug heading box
    drawBox(
      canvas: canvas,
      box: const Rect.fromLTRB(0.75, 1.00, 1.25, 0.75),
    );
    drawNumber(
      canvas: canvas,
      offset: const Offset(1.0, 0.875),
      size: fontSize,
      value: headingBug,
      minDigits: 3,
      align: TextAlign.center,
      color: const Color.fromRGBO(0, 192, 255, 1.0),
    );
  }

  static void drawTapeFlaps({
    required Canvas canvas,
    required double flaps,
  }) {
    if (flaps < 0.02) return;
    Paint white = paintWithColor(r: 1.0, g: 1.0, b: 1.0);
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          const Offset(-0.95, 0.0),
          const Offset(-0.93, 0.0),
          Offset(-0.93, flaps * 0.79),
          Offset(-0.95, flaps * 0.79),
        ],
      ),
      BlendMode.src,
      white,
    );
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          const Offset(0.95, 0.0),
          const Offset(0.93, 0.0),
          Offset(0.93, flaps * 0.79),
          Offset(0.95, flaps * 0.79),
        ],
      ),
      BlendMode.src,
      white,
    );
  }

  static void drawGear({
    required Canvas canvas,
    required int gearDownLights,
    required int gearUpLights,
  }) {
    // Choose up lights over down
    gearDownLights = gearDownLights & (~gearUpLights);
    int allGear = noseGear | leftGear | rightGear;
    bool allUp = ((gearUpLights & allGear) == allGear);
    Paint red = paintWithColor(r: 0.8, g: 0.0, b: 0.0);
    Paint green = paintWithColor(r: 0.0, g: 0.8, b: 0.0);
    Paint gray = paintWithColor(r: 0.3, g: 0.3, b: 0.3);
    double radius = 0.02;
    Offset nose = const Offset(0.0, 0.1);
    Offset left = const Offset(-0.1, 0.2);
    Offset right = const Offset(0.1, 0.2);

    if (gearDownLights & noseGear > 0) {
      // show landing gear
      canvas.drawCircle(
        nose,
        radius,
        green,
      );
    } else if (gearUpLights & noseGear > 0) {
      if (!allUp) {
        canvas.drawCircle(
          nose,
          radius,
          red,
        );
      }
    } else {
      // show transition
      canvas.drawCircle(
        nose,
        radius,
        gray,
      );
    }

    if (gearDownLights & leftGear > 0) {
      // show landing gear
      canvas.drawCircle(
        left,
        radius,
        green,
      );
    } else if (gearUpLights & leftGear > 0) {
      if (!allUp) {
        canvas.drawCircle(
          left,
          radius,
          red,
        );
      }
    } else {
      // show transition
      canvas.drawCircle(
        left,
        radius,
        gray,
      );
    }

    if (gearDownLights & rightGear > 0) {
      // show landing gear
      canvas.drawCircle(
        right,
        radius,
        green,
      );
    } else if (gearUpLights & rightGear > 0) {
      if (!allUp) {
        canvas.drawCircle(
          right,
          radius,
          red,
        );
      }
    } else {
      // show transition
      canvas.drawCircle(
        right,
        radius,
        gray,
      );
    }
  }

  static void drawElevatorTrim({
    required Canvas canvas,
    required double trim,
  }) {
    Paint centrePaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(0, 220, 0, 0.75)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint tabPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 1.0)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;

    double left = 1.65;
    double right = 1.9;
    double top = -0.8;
    double bottom = 0.8;
    double middle = (left + right) / 2.0;
    double width = right - left;
    double height = bottom - top;
    double centeredHeight = height / 40.0;
    double tabHeight = width * 0.7;
    double vertical = (top + bottom) / 2.0;
    trim = min(max(trim, -1.0), 1.0);
    drawBox(canvas: canvas, box: Rect.fromLTRB(left, top, right, bottom));
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(middle - width * 0.5, vertical - centeredHeight * 0.5),
          Offset(middle + width * 0.5, vertical - centeredHeight * 0.5),
          Offset(middle + width * 0.5, vertical + centeredHeight * 0.5),
          Offset(middle - width * 0.5, vertical + centeredHeight * 0.5),
        ],
      ),
      BlendMode.srcATop,
      centrePaint,
    );
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(middle, vertical - trim * height * 0.5),
          Offset(
            middle + width * 0.5,
            vertical - trim * height * 0.5 - tabHeight * 0.5,
          ),
          Offset(
            middle + width * 0.5,
            vertical - trim * height * 0.5 + tabHeight * 0.5,
          ),
        ],
      ),
      BlendMode.srcATop,
      tabPaint,
    );

    drawText(
      canvas: canvas,
      text: 'UP',
      offset: Offset(middle, vertical - height * 0.5 - 0.1),
    );
    drawText(
      canvas: canvas,
      text: 'DN',
      offset: Offset(middle, vertical + height * 0.5 + 0.1),
    );

    drawText(
      canvas: canvas,
      text: 'TRIM',
      offset: Offset(middle - width * 0.5 - 0.15, vertical),
      scale: 2.0,
      rotate: -90.0,
    );
  }

  static void drawRudderTrim({
    required Canvas canvas,
    required double trim,
  }) {
    Paint centrePaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(0, 220, 0, 0.75)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint tabPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 1.0)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;

    double left = -0.8;
    double right = 0.8;
    double top = 1.50;
    double bottom = 1.75;
    double middle = (left + right) / 2.0;
    double width = right - left;
    double height = bottom - top;
    double centeredWidth = width / 40.0;
    double tabHeight = height * 0.7;
    double vertical = (top + bottom) / 2.0;
    trim = min(max(trim, -1.0), 1.0);
    drawBox(canvas: canvas, box: Rect.fromLTRB(left, top, right, bottom));
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(middle - centeredWidth * 0.5, vertical - height * 0.5),
          Offset(middle + centeredWidth * 0.5, vertical - height * 0.5),
          Offset(middle + centeredWidth * 0.5, vertical + height * 0.5),
          Offset(middle - centeredWidth * 0.5, vertical + height * 0.5),
        ],
      ),
      BlendMode.srcATop,
      centrePaint,
    );
    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(middle + trim * width * 0.5, vertical),
          Offset(
            middle + trim * width * 0.5 - tabHeight * 0.5,
            vertical - height * 0.5,
          ),
          Offset(
            middle + trim * width * 0.5 + tabHeight * 0.5,
            vertical - height * 0.5,
          ),
        ],
      ),
      BlendMode.srcATop,
      tabPaint,
    );

    drawText(
      canvas: canvas,
      text: 'LT',
      offset: Offset(middle - width * 0.5 - 0.15, vertical),
    );
    drawText(
      canvas: canvas,
      text: 'RT',
      offset: Offset(middle + width * 0.5 + 0.15, vertical),
    );

    drawText(
      canvas: canvas,
      text: 'RUDDER TRIM',
      offset: Offset(middle, vertical - height * 0.5 - 0.15),
      scale: 2.0,
    );
  }

  static void drawAileronTrim({
    required Canvas canvas,
    required double trim,
  }) {}

  static void drawFlaps({
    required Canvas canvas,
    required double flaps,
  }) {
    Paint tabPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 1.0)
      ..strokeWidth = 1.0 / 256.0
      ..filterQuality = Settings.filterQuality;
    Paint linePaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..color = const Color.fromRGBO(255, 255, 255, 1.0)
      ..strokeWidth = 3.0 / 256.0
      ..filterQuality = Settings.filterQuality;

    double left = -1.9;
    double right = -1.65;
    double top = -0.8;
    double bottom = 0.8;
    double middle = (left + right) / 2.0;
    double width = right - left;
    double height = bottom - top;
    double tabHeight = width * 0.7;
    double vertical = (top + bottom) / 2.0;
    double markDistance = height / 4.0;
    flaps = min(max(flaps, 0.0), 1.0);
    drawBox(canvas: canvas, box: Rect.fromLTRB(left, top, right, bottom));
    canvas.drawPoints(
      PointMode.lines,
      [
        Offset(middle, top + markDistance),
        Offset(middle + width * 0.5, top + markDistance),
        Offset(middle, top + 2.0 * markDistance),
        Offset(middle + width * 0.5, top + 2.0 * markDistance),
        Offset(middle, top + 3.0 * markDistance),
        Offset(middle + width * 0.5, top + 3.0 * markDistance),
      ],
      linePaint,
    );

    canvas.drawVertices(
      Vertices(
        VertexMode.triangleFan,
        [
          Offset(middle, top + flaps * height),
          Offset(
            middle - width * 0.5,
            top + flaps * height - tabHeight * 0.5,
          ),
          Offset(
            middle - width * 0.5,
            top + flaps * height + tabHeight * 0.5,
          ),
        ],
      ),
      BlendMode.srcATop,
      tabPaint,
    );

    drawText(
      canvas: canvas,
      text: 'UP',
      offset: Offset(middle, vertical - height * 0.5 - 0.1),
    );
    drawText(
      canvas: canvas,
      text: 'DN',
      offset: Offset(middle, vertical + height * 0.5 + 0.1),
    );

    drawText(
      canvas: canvas,
      text: 'FLAPS',
      offset: Offset(middle + width * 0.5 + 0.15, vertical),
      scale: 2.0,
      rotate: -90.0,
    );
  }
}
