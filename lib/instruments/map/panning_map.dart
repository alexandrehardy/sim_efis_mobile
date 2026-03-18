import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/map/map_gesture_detector.dart';
import 'package:sim_efis/instruments/map/map_painter.dart';

class PanningMap extends StatefulWidget {
  final double aircraftLatitude;
  final double aircraftLongitude;
  final double mapLatitude;
  final double mapLongitude;
  final double mapHeading;
  final double aircraftHeading;
  final bool rotateMap;
  final int zoom;
  final double mapOffsetY;
  final double mapOffsetX;
  final double brightness;
  final Map<AirspaceType, bool> visibleAirspaceTypes;
  final Map<IcaoClass, bool> visibleAirspaceClasses;
  final bool showAirspaceLabels;
  final bool showNavAids;
  final bool showReportingPoints;
  final bool showAirports;
  final bool showAirspaces;
  final bool showParachuteJumpZones;
  final int minAirspaceAlt;
  final int maxAirspaceAlt;

  const PanningMap({
    Key? key,
    required this.aircraftLatitude,
    required this.aircraftLongitude,
    required this.mapLatitude,
    required this.mapLongitude,
    required this.mapHeading,
    required this.aircraftHeading,
    required this.rotateMap,
    required this.zoom,
    required this.mapOffsetY,
    required this.mapOffsetX,
    required this.brightness,
    required this.visibleAirspaceTypes,
    required this.visibleAirspaceClasses,
    required this.showAirspaceLabels,
    required this.showNavAids,
    required this.showReportingPoints,
    required this.showAirports,
    required this.showAirspaces,
    required this.showParachuteJumpZones,
    required this.minAirspaceAlt,
    required this.maxAirspaceAlt,
  }) : super(key: key);

  @override
  State<PanningMap> createState() => _PanningMapState();
}

class _PanningMapState extends State<PanningMap> {
  Offset panOffset = const Offset(0.0, 0.0);

  @override
  void didUpdateWidget(covariant PanningMap oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MapGestureDetector(
      heading: widget.rotateMap ? widget.mapHeading : 0.0,
      mapOffsetX: widget.mapOffsetX,
      mapOffsetY: widget.mapOffsetY,
      zoom: widget.zoom,
      onPanStart: () {
        panOffset = const Offset(0.0, 0.0);
        UiStateController.startPanMap(
          widget.mapHeading,
          widget.aircraftLatitude,
          widget.aircraftLongitude,
        );
      },
      onPan: (Offset pan) {
        setState(() {
          panOffset = pan;
        });
      },
      onPanEnd: (Offset pan) {
        // No setState here. Wait for
        // the ui streams to cause the rebuild
        panOffset = const Offset(0.0, 0.0);
        UiStateController.updatePanMap(
          -pan.dx + widget.mapOffsetX,
          -pan.dy + widget.mapOffsetY,
        );
      },
      child: CustomPaint(
        foregroundPainter: MapPainter(
          aircraftLatitude: widget.aircraftLatitude,
          aircraftLongitude: widget.aircraftLongitude,
          mapLatitude: widget.mapLatitude,
          mapLongitude: widget.mapLongitude,
          mapHeading: widget.mapHeading,
          aircraftHeading: widget.aircraftHeading,
          zoom: widget.zoom,
          rotateMap: widget.rotateMap,
          mapOffsetX: widget.mapOffsetX - panOffset.dx,
          mapOffsetY: widget.mapOffsetY - panOffset.dy,
          brightness: widget.brightness,
          visibleAirspaceTypes: widget.visibleAirspaceTypes,
          visibleAirspaceClasses: widget.visibleAirspaceClasses,
          showAirspaceLabels: widget.showAirspaceLabels,
          showAirports: widget.showAirports,
          showAirspaces: widget.showAirspaces,
          showNavAids: widget.showNavAids,
          showReportingPoints: widget.showReportingPoints,
          showParachuteJumpZones: widget.showParachuteJumpZones,
          minAirspaceAlt: widget.minAirspaceAlt,
          maxAirspaceAlt: widget.maxAirspaceAlt,
        ),
        isComplex: false,
        willChange: true,
        child: Container(),
      ),
    );
  }
}
