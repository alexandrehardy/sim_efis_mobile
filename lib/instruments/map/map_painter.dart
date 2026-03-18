import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/airspace_colors.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/textures.dart';
import 'package:sim_efis/tile_cache.dart';

class MapPainter extends CustomPainter {
  double aircraftLatitude;
  double aircraftLongitude;
  double mapLatitude;
  double mapLongitude;
  double mapHeading;
  double aircraftHeading;
  bool rotateMap;
  int zoom;
  double get darken => (brightness < 0.0) ? 1.0 + brightness : 1.0;
  double get lighten => (brightness > 0.0) ? brightness * 255 : 0.0;
  double brightness = 1.0;
  double mapOffsetY = 0.0;
  double mapOffsetX = 0.0;
  bool showAirspaces;
  Map<AirspaceType, bool> visibleAirspaceTypes;
  Map<IcaoClass, bool> visibleAirspaceClasses;
  bool showAirspaceLabels;
  bool showNavAids;
  bool showReportingPoints;
  bool showAirports;
  bool showParachuteJumpZones;
  int minAirspaceAlt;
  int maxAirspaceAlt;

  MapPainter({
    required this.aircraftLatitude,
    required this.aircraftLongitude,
    required this.mapLatitude,
    required this.mapLongitude,
    required this.mapHeading,
    required this.zoom,
    this.rotateMap = true,
    required this.mapOffsetX,
    required this.mapOffsetY,
    required this.aircraftHeading,
    required this.brightness,
    required this.visibleAirspaceTypes,
    required this.visibleAirspaceClasses,
    required this.showAirspaceLabels,
    required this.showNavAids,
    required this.showReportingPoints,
    required this.showAirports,
    required this.showAirspaces,
    required this.minAirspaceAlt,
    required this.maxAirspaceAlt,
    required this.showParachuteJumpZones,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is MapPainter) {
      return (oldDelegate.aircraftLatitude != aircraftLatitude) ||
          (oldDelegate.aircraftLongitude != aircraftLongitude) ||
          (oldDelegate.mapLatitude != mapLatitude) ||
          (oldDelegate.mapLongitude != mapLongitude) ||
          (oldDelegate.mapHeading != mapHeading) ||
          (oldDelegate.rotateMap != rotateMap) ||
          (oldDelegate.mapOffsetX != mapOffsetX) ||
          (oldDelegate.mapOffsetY != mapOffsetY) ||
          (oldDelegate.zoom != zoom) ||
          (oldDelegate.visibleAirspaceClasses != visibleAirspaceClasses) ||
          (oldDelegate.visibleAirspaceTypes != visibleAirspaceTypes) ||
          (oldDelegate.showAirspaceLabels != showAirspaceLabels) ||
          (oldDelegate.showAirspaces != showAirspaces) ||
          (oldDelegate.showAirports != showAirports) ||
          (oldDelegate.showNavAids != showNavAids) ||
          (oldDelegate.minAirspaceAlt != minAirspaceAlt) ||
          (oldDelegate.maxAirspaceAlt != maxAirspaceAlt) ||
          (oldDelegate.showReportingPoints != showReportingPoints) ||
          (oldDelegate.showParachuteJumpZones != showParachuteJumpZones);
    } else {
      return true;
    }
  }

  @override
  bool? hitTest(Offset position) => true;

  static Tile tileFor({
    required double latitude,
    required double longitude,
    required double mapOffsetX,
    required double mapOffsetY,
    required int zoom,
  }) {
    int n = pow(2, zoom).toInt();
    double latRadian = latitude / 180.0 * pi;
    double xTile = n * ((longitude + 180.0) / 360.0) + mapOffsetX / 256.0;
    double yTile =
        n * (1 - (log(tan(latRadian) + 1.0 / cos(latRadian)) / pi)) / 2.0 +
            mapOffsetY / 256.0;
    return Tile(
      x: xTile.toInt(),
      y: yTile.toInt(),
      n: n,
      zoom: zoom,
      offset: Offset(
        xTile - xTile.toInt(),
        yTile - yTile.toInt(),
      ),
    );
  }

  static double _tileLatitude(double y, int n) {
    double z = pi - 2.0 * pi * y / n.toDouble();
    return 180.0 / pi * atan(0.5 * (exp(z) - exp(-z)));
  }

  static double tileLatitude(Tile tile) {
    return _tileLatitude(tile.y + tile.offset.dy, tile.n);
  }

  static double tileSlippyX(Tile tile) {
    return (tile.x + tile.offset.dx) / tile.n.toDouble();
  }

  static double tileSlippyY(Tile tile) {
    return (tile.y + tile.offset.dy) / tile.n.toDouble();
  }

  static double _tileLongitude(double x, int n) {
    return x / n * 360.0 - 180.0;
  }

  static double tileLongitude(Tile tile) {
    return _tileLongitude(tile.x + tile.offset.dx, tile.n);
  }

  static double tileHeightDegrees(Tile tile) {
    return (_tileLatitude(tile.y + 1, tile.n) -
            _tileLatitude(tile.y.toDouble(), tile.n))
        .abs();
  }

  static double tileWidthDegrees(Tile tile) {
    return 360.0 / pow(2.0, tile.zoom.toDouble()).toDouble();
  }

  void drawTile({
    required Canvas canvas,
    required Tile tile,
    required Offset centre,
    required int xOffset, // grid x
    required int yOffset, // grid y
  }) {
    // TODO: The server name should not be part of the key
    int x = tile.x + xOffset;
    int y = tile.y + yOffset;

    if (x < 0) x += tile.n;
    if (y < 0) y += tile.n;
    ui.Image? image = TileMemoryCache.getTile(zoom, x, y);
    if (image == null) {
      return;
    }
    // TODO: The tile offset is expected to be (0.5, 0.5) when we
    // are in the middle. Correct for that.
    Offset origin = Offset(
      centre.dx -
          image.width / 2.0 +
          (xOffset - tile.offset.dx + 0.5) * image.width,
      centre.dy -
          image.height / 2.0 +
          (yOffset - tile.offset.dy + 0.5) * image.height,
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        0.0,
        0.0,
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      Rect.fromLTWH(
        origin.dx,
        origin.dy,
        image.width.toDouble() + 0.5,
        image.height.toDouble() + 0.5,
      ),
      Paint()
        ..colorFilter = ColorFilter.matrix([
          darken,
          0.0,
          0.0,
          0.0,
          lighten,
          0.0,
          darken,
          0.0,
          0.0,
          lighten,
          0.0,
          0.0,
          darken,
          0.0,
          lighten,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0
        ])
        ..blendMode = BlendMode.src
        ..filterQuality = Settings.filterQuality,
    );
  }

  double tileDistance(int zoom, double latitude) {
    double earthRadiusNm = 3443.8445;
    double latRadians = latitude / 180.0 * pi;
    int n = pow(2, zoom).toInt();
    double latitudeRadius = cos(latRadians) * earthRadiusNm;
    double latitudeCircumference = 2.0 * pi * latitudeRadius;
    double tileDistance = latitudeCircumference / n;
    return tileDistance;
  }

  Offset perpendicular(Offset first, Offset second) {
    Offset diff = second - first;
    double dist = diff.distance;
    if (dist < 0.0001) {
      dist = 0.0001;
    }
    return Offset(-diff.dy, diff.dx) / dist;
  }

  List<Offset> makeStrip(
    List<Offset> vertices,
    double width,
    bool reverseWinding,
  ) {
    List<Offset> strip = [];
    Offset first = vertices[0];
    Offset second = vertices[1];
    Offset perp = perpendicular(first, second);
    if (reverseWinding) {
      perp = -perp;
    }

    strip.add(first);
    strip.add(first + perp * width);
    strip.add(second);
    strip.add(second + perp * width);

    for (int index = 1; index < vertices.length - 1; index++) {
      first = second;
      second = vertices[index + 1];
      perp = perpendicular(first, second);
      if (reverseWinding) {
        perp = -perp;
      }
      strip.add(first + perp * width);
      strip.add(first);
      strip.add(first + perp * width);
      strip.add(second);
      strip.add(second + perp * width);
    }

    first = vertices.last;
    second = vertices.first;
    perp = perpendicular(first, second);
    if (reverseWinding) {
      perp = -perp;
    }

    strip.add(first + perp * width);
    strip.add(first);
    strip.add(first + perp * width);
    strip.add(second);
    strip.add(second + perp * width);
    return strip;
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
        ui.PointMode.polygon,
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

  void drawAirspaces(
    Canvas canvas,
    Size size,
    Tile tile,
    double latitude,
    double longitude,
    Offset centre,
    int zoom,
  ) {
    if (zoom < 5) {
      // Don't draw if we zoom too far out
      return;
    }
    if (Textures.hatch == null) {
      return;
    }
    int tileWidth = 256;
    int n = tile.n * tileWidth;
    double mapWidth = size.width / tileWidth * tileWidthDegrees(tile);
    double mapHeight = size.height / tileWidth * tileHeightDegrees(tile);
    double slippyX = tileSlippyX(tile);
    double slippyY = tileSlippyY(tile);

    canvas.save();
    if (rotateMap) {
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(-mapHeading / 180.0 * pi);
      canvas.translate(-centre.dx, -centre.dy);
    }
    canvas.translate(centre.dx, centre.dy);
    canvas.translate(-slippyX * n, -slippyY * n);
    try {
      if (showAirports) {
        List<Airport> airports = AirspaceCache.getAirports(
          minLatitude: (latitude - mapHeight),
          maxLatitude: (latitude + mapHeight),
          minLongitude: (longitude - mapWidth),
          maxLongitude: (longitude + mapWidth),
          zoom: zoom,
        );
        for (Airport airport in airports) {
          Offset base = Offset(
            airport.location.slippyX * n,
            airport.location.slippyY * n,
          );

          canvas.drawCircle(
            base,
            15,
            Paint()
              ..style = ui.PaintingStyle.stroke
              ..color = Colors.grey[800]!
              ..strokeWidth = 5,
          );

          List<Runway> mainRunways =
              airport.runways.where((runway) => runway.mainRunway).toList();
          double runwayHeading = 0.0;
          if (mainRunways.isNotEmpty) {
            runwayHeading = mainRunways[0].trueHeading.toDouble();
          }
          runwayHeading = runwayHeading * pi / 180.0;
          Offset direction =
              Offset(25 * sin(runwayHeading), -25 * cos(runwayHeading));
          canvas.drawLine(
              base - direction,
              base + direction,
              Paint()
                ..style = ui.PaintingStyle.stroke
                ..color = Colors.grey[800]!
                ..strokeWidth = 10);

          drawText(
            canvas: canvas,
            drawBox: true,
            drawBorder: false,
            text: airport.name,
            color: Colors.black,
            borderColor: Colors.white,
            where: base + const Offset(30, 0),
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
          );
        }
      }
      if (showReportingPoints) {
        List<ReportingPoint> reportingPoints = AirspaceCache.getReportingPoints(
          minLatitude: (latitude - mapHeight),
          maxLatitude: (latitude + mapHeight),
          minLongitude: (longitude - mapWidth),
          maxLongitude: (longitude + mapWidth),
          zoom: zoom,
        );
        for (ReportingPoint reportingPoint in reportingPoints) {
          Offset base = Offset(
            reportingPoint.location.slippyX * n,
            reportingPoint.location.slippyY * n,
          );

          canvas.drawPoints(
            ui.PointMode.polygon,
            [
              base + const Offset(0.0, -10.0),
              base + const Offset(-10.0, 10.0),
              base + const Offset(10.0, 10.0),
              base + const Offset(0.0, -10.0),
            ],
            Paint()
              ..style = ui.PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..color = Colors.red
              ..strokeWidth = 5,
          );

          drawText(
            canvas: canvas,
            drawBox: true,
            drawBorder: false,
            text: reportingPoint.name,
            color: Colors.black,
            borderColor: Colors.white,
            where: base + const Offset(30, 0),
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
          );
        }
      }
      if (showNavAids) {
        List<NavAid> navAids = AirspaceCache.getNavAids(
          minLatitude: (latitude - mapHeight),
          maxLatitude: (latitude + mapHeight),
          minLongitude: (longitude - mapWidth),
          maxLongitude: (longitude + mapWidth),
          zoom: zoom,
        );
        for (NavAid navAid in navAids) {
          Offset base = Offset(
            navAid.location.slippyX * n,
            navAid.location.slippyY * n,
          );
          for (int i = 0; i < 360; i += 90) {
            double angle = (navAid.magneticDeclination + i) * pi / 180.0;
            Offset dir = Offset(sin(angle), -cos(angle));
            canvas.drawLine(
              base + dir * 30,
              base + dir * 50,
              Paint()
                ..color = Colors.blue
                ..strokeWidth = 2,
            );
          }
          for (int i = 0; i < 360; i += 30) {
            double angle = (navAid.magneticDeclination + i) * pi / 180.0;
            Offset dir = Offset(sin(angle), -cos(angle));
            canvas.drawLine(
              base + dir * 30,
              base + dir * 50,
              Paint()
                ..color = Colors.blue
                ..strokeWidth = 1,
            );
          }
          for (int i = 0; i < 360; i += 10) {
            double angle = (navAid.magneticDeclination + i) * pi / 180.0;
            Offset dir = Offset(sin(angle), -cos(angle));
            canvas.drawLine(
              base + dir * 40,
              base + dir * 50,
              Paint()
                ..color = Colors.blue
                ..strokeWidth = 1,
            );
          }
          canvas.drawCircle(
            base,
            50,
            Paint()
              ..style = ui.PaintingStyle.stroke
              ..color = Colors.blue
              ..strokeWidth = 1,
          );
          for (int i = 0; i < 36; i += 9) {
            double angle = (navAid.magneticDeclination + i * 10) * pi / 180.0;
            canvas.save();
            canvas.translate(base.dx, base.dy);
            canvas.rotate(angle);
            drawText(
              canvas: canvas,
              text: '$i',
              color: Colors.blue,
              where: const Offset(0, -30),
              textAlign: TextAlign.center,
              fontSize: 10,
            );
            canvas.restore();
          }

          drawText(
            canvas: canvas,
            drawBox: false,
            drawBorder: false,
            text: navAid.identifier,
            color: Colors.black,
            borderColor: Colors.white,
            where: base + const Offset(00, 0),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
          );
        }
      }

      if (showAirspaces) {
        List<Airspace> airspaces = AirspaceCache.getAirspaces(
          minLatitude: (latitude - mapHeight),
          maxLatitude: (latitude + mapHeight),
          minLongitude: (longitude - mapWidth),
          maxLongitude: (longitude + mapWidth),
          zoom: zoom,
        );
        airspaces = airspaces
            .where((a) =>
                (visibleAirspaceTypes[a.type] ?? true) &&
                (visibleAirspaceClasses[a.icaoClass] ?? true) &&
                (a.upperLimit.feet > minAirspaceAlt) &&
                (a.lowerLimit.feet < maxAirspaceAlt))
            .toList();
        if (!showParachuteJumpZones) {
          airspaces = airspaces
              .where((a) => !a.name.toUpperCase().startsWith('PJE'))
              .toList();
        }
        for (Airspace airspace in airspaces) {
          Color airspaceColor = getAirspaceColor(airspace);
          if (zoom > 8) {
            canvas.drawVertices(
              ui.Vertices(
                VertexMode.triangleStrip,
                makeStrip(
                  airspace.airspace
                      .map((e) => Offset(
                            e.slippyX * n,
                            e.slippyY * n,
                          ))
                      .toList(),
                  10.0,
                  airspace.reverseWinding,
                ),
                //textureCoordinates: ,
              ),
              BlendMode.srcOver,
              Paint()
                ..shader = ImageShader(
                  Textures.hatch!,
                  TileMode.repeated,
                  TileMode.repeated,
                  Matrix4.diagonal3Values(0.2, 0.2, 1.0).storage,
                )
                ..blendMode = BlendMode.srcOver
                ..color = airspaceColor
                ..colorFilter = ColorFilter.mode(
                  airspaceColor,
                  BlendMode.srcATop,
                )
                ..filterQuality = Settings.filterQuality,
            );
          }

          canvas.drawPoints(
            ui.PointMode.polygon,
            airspace.airspace
                .map((e) => Offset(
                      e.slippyX * n,
                      e.slippyY * n,
                    ))
                .toList(),
            Paint()
              ..strokeWidth = 2
              ..blendMode = BlendMode.srcOver
              ..color = airspaceColor
              ..colorFilter = ColorFilter.mode(
                airspaceColor,
                BlendMode.srcATop,
              )
              ..filterQuality = Settings.filterQuality,
          );
        }

        if (showAirspaceLabels) {
          for (Airspace airspace in airspaces) {
            Color airspaceColor = getAirspaceColor(airspace);
            if (airspace.minZoom + 1 <= zoom) {
              Offset labelPosition = Offset(
                airspace.centre.slippyX * n,
                airspace.centre.slippyY * n,
              );
              String name = airspace.name.split(' ')[0];
              String lower = airspace.lowerLimit.toString();
              String upper = airspace.upperLimit.toString();
              String boxText = '$name\n$upper\n$lower';
              drawText(
                canvas: canvas,
                drawBox: true,
                drawBorder: true,
                text: boxText,
                color: Colors.black,
                borderColor: airspaceColor,
                where: labelPosition,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
              );
            }
          }
        }
      }
    } catch (e, s) {
      Logger.log('AIRSPACE FAILURE: $e $s');
    }
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<double> scales = [
      0.5,
      1.0,
      2.0,
      5.0,
      10.0,
      20.0,
      50.0,
      100.0,
      200.0,
      500.0,
      1000.0,
      2000.0,
      4000.0,
      1e6,
    ];
    List<String> scaleText = [
      '0.5 nm',
      '1 nm',
      '2 nm',
      '5 nm',
      '10 nm',
      '20 nm',
      '50 nm',
      '100 nm',
      '200 nm',
      '500 nm',
      '1000 nm',
      '2000 nm',
      '4000 nm',
    ];

    int tileSize = 256;
    int tilesRequired =
        ((max(size.width, size.height)) / (tileSize * 2.0)).ceil();
    Tile tile = tileFor(
      latitude: mapLatitude,
      longitude: mapLongitude,
      mapOffsetX: mapOffsetX,
      mapOffsetY: mapOffsetY,
      zoom: zoom,
    );
    double longPixelsToDegrees = tileWidthDegrees(tile) / tileSize;
    // TODO: Figure out the correct scale.
    double latPixelsToDegrees = tileHeightDegrees(tile) / tileSize;
    double centreTileLatitude = tileLatitude(tile);
    double centreTileLongitude = tileLongitude(tile);

    canvas.clipRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    canvas.save();
    Offset centre = Offset(size.width / 2.0, size.height / 2.0);
    if (rotateMap) {
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(-mapHeading / 180.0 * pi);
      canvas.translate(-centre.dx, -centre.dy);
    }

    // radiate outwards
    drawTile(
      canvas: canvas,
      tile: tile,
      centre: centre,
      xOffset: 0,
      yOffset: 0,
    );

    for (int i = 1; i <= tilesRequired + 1; i++) {
      for (int x = -i; x <= i; x++) {
        drawTile(
          canvas: canvas,
          tile: tile,
          centre: centre,
          xOffset: x,
          yOffset: -i,
        );
        drawTile(
          canvas: canvas,
          tile: tile,
          centre: centre,
          xOffset: x,
          yOffset: i,
        );
      }

      for (int y = -i + 1; y < i; y++) {
        drawTile(
          canvas: canvas,
          tile: tile,
          centre: centre,
          xOffset: -i,
          yOffset: y,
        );
        drawTile(
          canvas: canvas,
          tile: tile,
          centre: centre,
          xOffset: i,
          yOffset: y,
        );
      }
    }

    canvas.restore();
    drawAirspaces(
      canvas,
      size,
      tile,
      centreTileLatitude,
      centreTileLongitude,
      centre,
      zoom,
    );

    if (Textures.aircraft != null) {
      canvas.save();
      if (rotateMap) {
        canvas.translate(centre.dx, centre.dy);
        canvas.rotate(-mapHeading / 180.0 * pi);
        canvas.translate(-centre.dx, -centre.dy);
      }
      canvas.translate(
        -mapOffsetX + (aircraftLongitude - mapLongitude) / longPixelsToDegrees,
        -mapOffsetY - (aircraftLatitude - mapLatitude) / latPixelsToDegrees,
      );
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(aircraftHeading / 180.0 * pi);
      canvas.drawImageRect(
        Textures.aircraft!,
        Rect.fromLTWH(
          0.0,
          0.0,
          Textures.aircraft!.width.toDouble(),
          Textures.aircraft!.height.toDouble(),
        ),
        const Rect.fromLTWH(
          -25,
          -25,
          50,
          50,
        ),
        Paint()
          ..blendMode = BlendMode.srcOver
          ..color = Colors.red
          ..colorFilter = const ColorFilter.mode(
            Colors.red,
            BlendMode.srcATop,
          )
          ..filterQuality = Settings.filterQuality,
      );
      canvas.restore();

      double baseDistance = tileDistance(zoom, aircraftLatitude) * 0.5;
      double tapeLength = 0.0;
      int distanceIndex = 1;

      for (int i = 0; scales[i] < 1e5; i++) {
        if (baseDistance < scales[i]) {
          distanceIndex = i;
          break;
        }
      }

      tapeLength = scales[distanceIndex] / baseDistance * tileSize * 0.5;

      canvas.drawPoints(
          ui.PointMode.lines,
          [
            Offset(10.0, size.height - 10.0),
            Offset(10.0, size.height - 20.0),
            Offset(10.0, size.height - 15.0),
            Offset(10.0 + tapeLength, size.height - 15.0),
            Offset(10.0 + tapeLength, size.height - 10.0),
            Offset(10.0 + tapeLength, size.height - 20.0),
          ],
          Paint()
            ..blendMode = BlendMode.srcOver
            ..color = const Color.fromRGBO(255, 0, 0, 0.7)
            ..filterQuality = Settings.filterQuality
            ..strokeWidth = 4.0);

      drawText(
        canvas: canvas,
        text: scaleText[distanceIndex],
        color: const Color.fromRGBO(255, 0, 0, 0.7),
        where: Offset(
          (tapeLength + 20.0) / 2.0,
          size.height - 40.0,
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}
