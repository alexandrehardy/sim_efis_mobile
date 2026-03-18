import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/map/panning_map.dart';
import 'package:sim_efis/widgets/circular_icon.dart';

class MapWidget extends StatelessWidget {
  static const int maxZoom = 16;
  static const int minZoom = 3;

  const MapWidget({
    Key? key,
  }) : super(key: key);

  int displayAltitude(double altitude) {
    if (altitude < 1000.0) {
      return altitude.toInt();
    }
    int roundedAlt = altitude.toInt();
    return roundedAlt - roundedAlt % 100;
  }

  Widget buildControlStack({
    required InstrumentState state,
    required int zoom,
    required rotateMap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          child: Transform.rotate(
            angle: -pi / 4.0 +
                ((!rotateMap) ? 0.0 : -state.trueHeading * pi / 180.0),
            child: const CircularIconWidget(
              icon: CupertinoIcons.compass,
              size: 50,
              iconSize: 42,
              padding: 0,
            ),
          ),
          onTap: () {
            UiStateController.toggleRotateMap();
          },
        ),
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.airplanemode_active,
            size: 50,
            iconSize: 42,
            padding: 7,
          ),
          onTap: () {
            UiStateController.resetMap();
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.add,
            size: 50,
            iconSize: 42,
            padding: 4,
          ),
          onTap: () {
            if (zoom < maxZoom) {
              UiStateController.setMapZoom(zoom + 1);
            }
          },
        ),
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.remove,
            size: 50,
            iconSize: 42,
            padding: 4,
          ),
          onTap: () {
            if (zoom > minZoom) {
              UiStateController.setMapZoom(zoom - 1);
            }
          },
        ),
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.settings,
            size: 50,
            iconSize: 42,
            padding: 4,
          ),
          onTap: () {
            if (UiStateController.state.firstPage == EfisPage.map) {
              if (UiStateController.state.overlaySecondPage ==
                  EfisPage.mapSettings) {
                UiStateController.overlaySecondPage(EfisPage.none);
              } else {
                UiStateController.overlaySecondPage(EfisPage.mapSettings);
              }
            } else {
              if (UiStateController.state.overlayFirstPage ==
                  EfisPage.mapSettings) {
                UiStateController.overlayFirstPage(EfisPage.none);
              } else {
                UiStateController.overlayFirstPage(EfisPage.mapSettings);
              }
            }
          },
        ),
      ],
    );
  }

  Widget buildMapWidget({
    required BuildContext context,
    required int zoom,
    required bool rotateMap,
    required double mapOffsetX,
    required double mapOffsetY,
    required double brightness,
    double? lockedLatitude,
    double? lockedLongitude,
    double? heading,
    required Map<AirspaceType, bool> visibleAirspaceTypes,
    required Map<IcaoClass, bool> visibleAirspaceClasses,
    required bool showAirspaceLabels,
    required bool showNavAids,
    required bool showReportingPoints,
    required bool showAirports,
    required bool showAirspaces,
    required bool showParachuteJumpZones,
    required int minAirspaceAlt,
    required int maxAirspaceAlt,
  }) {
    return StreamBuilder(
      initialData: InstrumentDataStream.instance.current,
      stream: InstrumentDataStream.instance.stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<InstrumentState> snapshot,
      ) =>
          Stack(
        clipBehavior: Clip.none,
        children: [
          PanningMap(
            mapLatitude: lockedLatitude ?? snapshot.requireData.latitude,
            mapLongitude: lockedLongitude ?? snapshot.requireData.longitude,
            aircraftLatitude: snapshot.requireData.latitude,
            aircraftLongitude: snapshot.requireData.longitude,
            mapHeading: heading ?? snapshot.requireData.trueHeading,
            aircraftHeading: snapshot.requireData.trueHeading,
            zoom: zoom,
            rotateMap: rotateMap,
            mapOffsetX: mapOffsetX,
            mapOffsetY: mapOffsetY,
            brightness: brightness,
            visibleAirspaceClasses: visibleAirspaceClasses,
            visibleAirspaceTypes: visibleAirspaceTypes,
            showAirspaceLabels: showAirspaceLabels,
            showNavAids: showNavAids,
            showReportingPoints: showReportingPoints,
            showAirports: showAirports,
            showAirspaces: showAirspaces,
            showParachuteJumpZones: showParachuteJumpZones,
            minAirspaceAlt: minAirspaceAlt,
            maxAirspaceAlt: maxAirspaceAlt,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: buildControlStack(
                state: snapshot.requireData,
                zoom: zoom,
                rotateMap: rotateMap,
              ),
            ),
          ),
          const Positioned(
            bottom: 12,
            right: 10,
            child: Text(
              'map data: © OpenStreetMap contributors, SRTM',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            right: 10,
            child: Text(
              'map style: © OpenTopoMap (CC-BY-SA)',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 10,
            child: Text(
              'Altitude: ${displayAltitude(snapshot.requireData.altitude)} ft',
              style: const TextStyle(
                color: Color.fromRGBO(255, 0, 0, 0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 10,
            child: Text(
              'Airspeed: ${snapshot.requireData.indicatedAirspeed.toInt()} kts',
              style: const TextStyle(
                color: Color.fromRGBO(255, 0, 0, 0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UiState>(
        initialData: UiStateController.state,
        stream: UiStateController.stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<UiState> snapshot,
        ) =>
            buildMapWidget(
              context: context,
              zoom: snapshot.requireData.mapZoom,
              rotateMap: snapshot.requireData.rotateMap,
              mapOffsetX: snapshot.requireData.mapOffsetX,
              mapOffsetY: snapshot.requireData.mapOffsetY,
              brightness: snapshot.requireData.mapBrightness,
              heading: (snapshot.requireData.freeMap)
                  ? snapshot.requireData.mapHeading
                  : null,
              lockedLatitude: (snapshot.requireData.freeMap)
                  ? snapshot.requireData.lockedLatitude
                  : null,
              lockedLongitude: (snapshot.requireData.freeMap)
                  ? snapshot.requireData.lockedLongitude
                  : null,
              visibleAirspaceClasses:
                  snapshot.requireData.visibleAirspaceClasses,
              visibleAirspaceTypes: snapshot.requireData.visibleAirspaceTypes,
              showAirspaceLabels: snapshot.requireData.showAirspaceLabels,
              showAirspaces: snapshot.requireData.showAirspaces,
              showAirports: snapshot.requireData.showAirports,
              showNavAids: snapshot.requireData.showNavAids,
              showReportingPoints: snapshot.requireData.showReportingPoints,
              showParachuteJumpZones:
                  snapshot.requireData.showParachuteJumpZones,
              minAirspaceAlt: snapshot.requireData.minAirspaceAlt,
              maxAirspaceAlt: snapshot.requireData.maxAirspaceAlt,
            ));
  }
}
