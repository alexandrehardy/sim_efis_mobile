import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/airspace_colors.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/textures.dart';
import 'package:sim_efis/vector.dart';

class AirspacePainter extends CustomPainter {
  double latitude;
  double longitude;
  double heading;
  double altitude;
  double pitch;
  double airspeed;
  double vsi;
  bool showAirspaceLabels;
  int scale;

  AirspacePainter({
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.altitude,
    required this.pitch,
    required this.showAirspaceLabels,
    required this.airspeed,
    required this.vsi,
    required this.scale,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is AirspacePainter) {
      return (oldDelegate.latitude != latitude) ||
          (oldDelegate.longitude != longitude) ||
          (oldDelegate.heading != heading) ||
          (oldDelegate.altitude != altitude) ||
          (oldDelegate.pitch != pitch) ||
          (oldDelegate.airspeed != airspeed) ||
          (oldDelegate.vsi != vsi) ||
          (oldDelegate.showAirspaceLabels != showAirspaceLabels);
    } else {
      return true;
    }
  }

  void drawText({
    required Canvas canvas,
    required String text,
    required Color color,
    required Offset where,
    Color? borderColor,
    bool drawBox = false,
    bool drawBorder = false,
    double fontSize = 14,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical = TextAlignVertical.top,
    double padding = 10,
  }) {
    Offset? location = where;
    borderColor ??= color;
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    switch (textAlignVertical) {
      case TextAlignVertical.bottom:
        location = Offset(location.dx, location.dy - tp.height);
        break;
      case TextAlignVertical.top:
        break;
      case TextAlignVertical.center:
        location = Offset(location.dx, location.dy - tp.height / 2);
        break;
    }

    switch (textAlign) {
      case TextAlign.left:
        break;
      case TextAlign.start:
        break;
      case TextAlign.right:
        location = Offset(location.dx - tp.width, location.dy);
        break;
      case TextAlign.end:
        location = Offset(location.dx - tp.width, location.dy);
        break;
      case TextAlign.center:
        location = Offset(location.dx - tp.width / 2, location.dy);
        break;
      case TextAlign.justify:
        break;
    }

    if (drawBox) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            location.dx + tp.width / 2,
            location.dy + tp.height / 2,
          ),
          width: tp.width + 2 * padding,
          height: tp.height + 2 * padding,
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..blendMode = BlendMode.srcOver,
      );
    }
    if (drawBorder) {
      canvas.drawPoints(
        PointMode.polygon,
        [
          Offset(
            location.dx - padding,
            location.dy - padding,
          ),
          Offset(
            location.dx + tp.width + padding,
            location.dy - padding,
          ),
          Offset(
            location.dx + tp.width + padding,
            location.dy + tp.height + padding,
          ),
          Offset(
            location.dx - padding,
            location.dy + tp.height + padding,
          ),
          Offset(
            location.dx - padding,
            location.dy - padding,
          ),
        ],
        Paint()
          ..color = borderColor
          ..blendMode = BlendMode.src
          ..strokeWidth = 2,
      );
    }

    tp.paint(
      canvas,
      location,
    );
  }

  Vector project({
    required Coordinate coordinate,
    required Vector base,
  }) {
    Vector cv = Vector.from(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
    );
    double length = acos(base.dot(cv));
    Vector heading = cv - base;
    Vector tangentialHeading = heading - base * heading.dot(base);
    tangentialHeading = tangentialHeading.normalize();
    return tangentialHeading * length;
  }

  Vector headingVector({
    required Vector base,
    required double heading,
  }) {
    Vector north = Vector(x: 0, y: 1, z: 0) - base;
    Vector tangent = base.tangent() - base;
    north = north - base * north.dot(base);
    north = north.normalize();
    tangent = tangent - base * tangent.dot(base);
    tangent = tangent.normalize();
    double radians = -heading * pi / 180.0;
    return north * cos(radians) + tangent * sin(radians);
  }

  double intersect({
    required Vector heading,
    required Vector start,
    required Vector end,
  }) {
    // http://paulbourke.net/geometry/pointlineplane/
    double x1 = start.x;
    double y1 = start.y;
    double z1 = start.z;
    double x2 = end.x;
    double y2 = end.y;
    double z2 = end.z;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    double x4 = heading.x;
    double y4 = heading.y;
    double z4 = heading.z;
    double d1343 =
        (x1 - x3) * (x4 - x3) + (y1 - y3) * (y4 - y3) + (z1 - z3) * (z4 - z3);
    double d4321 =
        (x4 - x3) * (x2 - x1) + (y4 - y3) * (y2 - y1) + (z4 - z3) * (z2 - z1);
    double d1321 =
        (x1 - x3) * (x2 - x1) + (y1 - y3) * (y2 - y1) + (z1 - z3) * (z2 - z1);
    double d4343 =
        (x4 - x3) * (x4 - x3) + (y4 - y3) * (y4 - y3) + (z4 - z3) * (z4 - z3);
    double d2121 =
        (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
    double a = d1343 * d4321 - d1321 * d4343;
    double b = d2121 * d4343 - d4321 * d4321;
    if (b.abs() < 1e-10) {
      return -1.0;
    }
    return a / b;
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<Airspace> currentAirspaces = [];
    double airspaceCurrentTextSize = 40;
    double airspaceCanvasHeight = size.height - airspaceCurrentTextSize;
    double aircraftOffset = 50.0;
    double scale = pow(2.0, this.scale.toDouble()).toDouble();
    canvas.save();
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    canvas.clipRect(Rect.fromLTWH(
      0.0,
      airspaceCurrentTextSize,
      size.width,
      airspaceCanvasHeight,
    ));
    List<Airspace> airspaces = AirspaceCache.getAirspaces(
      minLatitude: (latitude - 1),
      maxLatitude: (latitude + 1),
      minLongitude: (longitude - 1),
      maxLongitude: (longitude + 1),
      zoom: 20,
    );
    Vector base = Vector.from(latitude: latitude, longitude: longitude);
    Vector hv = headingVector(base: base, heading: heading);
    double topAltitude = 10000;
    double bottomAltitude = altitude - 5000;
    if (bottomAltitude < 0.0) {
      bottomAltitude = 0.0;
    }
    topAltitude = bottomAltitude + 10000;
    for (Airspace airspace in airspaces) {
      Color airspaceColor = getAirspaceColor(airspace).withAlpha(128);
      if (airspace.lowerLimit.feet > topAltitude) {
        continue;
      }
      double lower = airspaceCanvasHeight -
          (airspace.lowerLimit.feet - bottomAltitude) /
              (topAltitude - bottomAltitude) *
              airspaceCanvasHeight +
          airspaceCurrentTextSize;
      double upper = airspaceCanvasHeight -
          (airspace.upperLimit.feet - bottomAltitude) /
              (topAltitude - bottomAltitude) *
              airspaceCanvasHeight +
          airspaceCurrentTextSize;
      List<Vector> bounds = [];
      if (airspace.airspace.isNotEmpty) {
        bounds.add(project(coordinate: airspace.airspace.last, base: base));
        for (Coordinate c in airspace.airspace) {
          Vector coord = project(coordinate: c, base: base);
          bounds.add(coord);
        }
      }
      List<Offset> coords = [];
      List<Offset> boundary = [];
      double distanceToBoundary = 1e15;
      double maxDistance = -1e-15;
      for (int i = 0; i < bounds.length - 1; i++) {
        Vector start = bounds[i];
        Vector end = bounds[i + 1];
        double t = intersect(
          heading: hv,
          start: start,
          end: end,
        );
        if ((t >= 0.0 - 1e-7) && (t <= 1.0 + 1e-7)) {
          double distance =
              (start + (end - start) * t).dot(hv) * 21639.0 / (2.0 * pi);
          if (distance < distanceToBoundary) {
            distanceToBoundary = distance;
          }
          if (distance > maxDistance) {
            maxDistance = distance;
          }
          coords.add(Offset(distance * scale + aircraftOffset, upper));
          coords.add(Offset(distance * scale + aircraftOffset, lower));
          boundary.add(Offset(distance * scale + aircraftOffset, upper));
        }
      }
      if (distanceToBoundary * scale + aircraftOffset > size.width) {
        continue;
      }

      List<Offset> temp =
          boundary.reversed.map((e) => Offset(e.dx, lower)).toList();
      boundary.addAll(temp);
      if (coords.isNotEmpty) {
        if ((distanceToBoundary <= 0.0) && (maxDistance >= 0.0)) {
          if ((airspace.lowerLimit.feet <= altitude) &&
              (airspace.upperLimit.feet >= altitude)) {
            currentAirspaces.add(airspace);
          }
        }
        canvas.drawVertices(
          Vertices(VertexMode.triangleStrip, coords),
          BlendMode.srcATop,
          Paint()..color = airspaceColor,
        );
        canvas.drawPoints(
          PointMode.polygon,
          boundary,
          Paint()
            ..color = airspaceColor.withAlpha(255)
            ..strokeWidth = 2,
        );
        if (showAirspaceLabels) {
          double start = coords.map((e) => e.dx).reduce(min);
          double end = coords.map((e) => e.dx).reduce(max);
          if (start < 0) {
            start = 0.0;
          }
          if (end > size.width) {
            end = size.width;
          }
          if (end - start > 60) {
            double labelVerticalPos = upper;
            double labelHorizontalPos = (start + end) / 2;
            if (labelVerticalPos < 0) {
              labelVerticalPos = 0;
            }
            if ((labelHorizontalPos < 50) && (end - 50 > 60)) {
              labelHorizontalPos = 50;
            }
            if ((labelHorizontalPos > size.width - 50) &&
                (size.width - 50 - end > 60)) {
              labelHorizontalPos = size.width - 50;
            }
            String label = airspace.name.split(' ')[0];
            drawText(
              canvas: canvas,
              text: label,
              color: Colors.black,
              where: Offset(
                labelHorizontalPos,
                labelVerticalPos + 5,
              ),
              textAlign: TextAlign.center,
            );
            if (distanceToBoundary > 0.0) {
              label = '${distanceToBoundary.toInt()} nm';
              drawText(
                canvas: canvas,
                text: label,
                color: Colors.black,
                where: Offset(
                  labelHorizontalPos,
                  labelVerticalPos + 20,
                ),
                textAlign: TextAlign.center,
              );
            }
          }
        }
      }
    }

    for (int i = 0; i < 40000; i += 1000) {
      double y = airspaceCanvasHeight -
          (i - bottomAltitude) /
              (topAltitude - bottomAltitude) *
              airspaceCanvasHeight +
          airspaceCurrentTextSize;
      canvas.drawLine(
          Offset(0, y),
          Offset(10, y),
          Paint()
            ..color = Colors.black54
            ..strokeWidth = 1.5);
      canvas.drawLine(
          Offset(size.width, y),
          Offset(size.width - 10, y),
          Paint()
            ..color = Colors.black54
            ..strokeWidth = 1.5);
      drawText(
        canvas: canvas,
        text: '$i',
        color: Colors.black54,
        where: Offset(size.width - 15, y),
        textAlign: TextAlign.end,
        textAlignVertical: TextAlignVertical.center,
      );
    }

    if (Textures.aircraftSide != null) {
      double aircraftY = airspaceCanvasHeight -
          (altitude - bottomAltitude) /
              (topAltitude - bottomAltitude) *
              airspaceCanvasHeight +
          airspaceCurrentTextSize;
      canvas.drawLine(
        Offset(aircraftOffset, airspaceCurrentTextSize),
        Offset(aircraftOffset, size.height),
        Paint()..color = Colors.black54,
      );
      double altPixels =
          -vsi * 60 / (topAltitude - bottomAltitude) * airspaceCanvasHeight;
      double distPixels = airspeed * scale;
      canvas.drawLine(
        Offset(aircraftOffset, aircraftY),
        Offset(aircraftOffset + distPixels, aircraftY + altPixels),
        Paint()..color = Colors.black54,
      );
      canvas.save();
      canvas.translate(aircraftOffset, aircraftY);
      canvas.rotate(-pitch / 180.0 * pi);

      canvas.drawImageRect(
        Textures.aircraftSide!,
        Rect.fromLTWH(
          0.0,
          0.0,
          Textures.aircraft!.width.toDouble(),
          Textures.aircraft!.height.toDouble(),
        ),
        const Rect.fromLTRB(
          -50,
          -50,
          50,
          50,
        ),
        Paint()
          ..blendMode = BlendMode.srcOver
          ..colorFilter = const ColorFilter.mode(
            Colors.red,
            BlendMode.modulate,
          )
          ..filterQuality = Settings.filterQuality,
      );
      canvas.restore();
    }
    canvas.restore();
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      0.0,
      0.0,
      size.width,
      airspaceCurrentTextSize,
    ));
    double offset = 5.0;
    drawText(
      canvas: canvas,
      text: 'IN:',
      color: Colors.black,
      fontSize: 16,
      where: Offset(60, offset),
    );
    String extra = '';
    for (Airspace airspace in currentAirspaces.take(2)) {
      drawText(
        canvas: canvas,
        text: '${airspace.name}$extra',
        color: Colors.black,
        fontSize: 16,
        where: Offset(90, offset),
      );
      offset += 16.0;
      if (currentAirspaces.length > 2) {
        extra = ' (+${currentAirspaces.length - 2})';
      }
    }
    canvas.restore();
  }
}
