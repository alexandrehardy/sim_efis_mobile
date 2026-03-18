import 'dart:async';

import 'package:sim_efis/airspace.dart';

enum SelectedPage { first, second }

enum EfisPage {
  airports,
  airspace,
  checklist,
  engine,
  flightLog,
  gear,
  map,
  mapSettings,
  ninePack,
  none,
  params,
  primaryFlightDisplay,
  selector,
  sixPack,
  twelvePack,
}

class UiState {
  final EfisPage overlayFirstPage;
  final EfisPage overlaySecondPage;
  final EfisPage firstPage;
  final EfisPage secondPage;
  final bool connected;
  final bool flightOpen;
  final int mapZoom;
  final bool rotateMap;
  final String activeCheckList;
  final List<String> availableCheckLists;
  final String listenOn;
  final int headingBug;
  final int altitudeBug;
  final bool increaseBug;
  final bool fixBug;
  final bool freeMap;
  final double lockedLatitude;
  final double lockedLongitude;
  final double mapOffsetX;
  final double mapOffsetY;
  final double mapHeading;
  final double mapBrightness;
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
  final int airspaceZoom;

  UiState copyWith({
    EfisPage? overlayFirstPage,
    EfisPage? overlaySecondPage,
    EfisPage? firstPage,
    EfisPage? secondPage,
    bool? connected,
    bool? flightOpen,
    int? mapZoom,
    bool? rotateMap,
    String? activeCheckList,
    List<String>? availableCheckLists,
    String? listenOn,
    int? headingBug,
    int? altitudeBug,
    bool? increaseBug,
    bool? fixBug,
    bool? freeMap,
    double? mapOffsetY,
    double? mapOffsetX,
    double? mapHeading,
    double? lockedLatitude,
    double? lockedLongitude,
    double? mapBrightness,
    Map<AirspaceType, bool>? visibleAirspaceTypes,
    Map<IcaoClass, bool>? visibleAirspaceClasses,
    bool? showAirspaceLabels,
    bool? showNavAids,
    bool? showReportingPoints,
    bool? showAirports,
    bool? showAirspaces,
    bool? showParachuteJumpZones,
    int? minAirspaceAlt,
    int? maxAirspaceAlt,
    int? airspaceZoom,
  }) {
    return UiState(
      overlayFirstPage: overlayFirstPage ?? this.overlayFirstPage,
      overlaySecondPage: overlaySecondPage ?? this.overlaySecondPage,
      firstPage: firstPage ?? this.firstPage,
      secondPage: secondPage ?? this.secondPage,
      connected: connected ?? this.connected,
      flightOpen: flightOpen ?? this.flightOpen,
      mapZoom: mapZoom ?? this.mapZoom,
      rotateMap: rotateMap ?? this.rotateMap,
      activeCheckList: activeCheckList ?? this.activeCheckList,
      availableCheckLists: availableCheckLists ?? this.availableCheckLists,
      listenOn: listenOn ?? this.listenOn,
      headingBug: headingBug ?? this.headingBug,
      altitudeBug: altitudeBug ?? this.altitudeBug,
      increaseBug: increaseBug ?? this.increaseBug,
      fixBug: fixBug ?? this.fixBug,
      freeMap: freeMap ?? this.freeMap,
      mapOffsetY: mapOffsetY ?? this.mapOffsetY,
      mapOffsetX: mapOffsetX ?? this.mapOffsetX,
      mapHeading: mapHeading ?? this.mapHeading,
      lockedLatitude: lockedLatitude ?? this.lockedLatitude,
      lockedLongitude: lockedLongitude ?? this.lockedLongitude,
      mapBrightness: mapBrightness ?? this.mapBrightness,
      visibleAirspaceTypes: visibleAirspaceTypes ?? this.visibleAirspaceTypes,
      visibleAirspaceClasses:
          visibleAirspaceClasses ?? this.visibleAirspaceClasses,
      showAirspaceLabels: showAirspaceLabels ?? this.showAirspaceLabels,
      showNavAids: showNavAids ?? this.showNavAids,
      showReportingPoints: showReportingPoints ?? this.showReportingPoints,
      showAirports: showAirports ?? this.showAirports,
      showAirspaces: showAirspaces ?? this.showAirspaces,
      showParachuteJumpZones:
          showParachuteJumpZones ?? this.showParachuteJumpZones,
      minAirspaceAlt: minAirspaceAlt ?? this.minAirspaceAlt,
      maxAirspaceAlt: maxAirspaceAlt ?? this.maxAirspaceAlt,
      airspaceZoom: airspaceZoom ?? this.airspaceZoom,
    );
  }

  const UiState({
    required this.overlayFirstPage,
    required this.overlaySecondPage,
    required this.firstPage,
    required this.secondPage,
    required this.connected,
    required this.flightOpen,
    required this.mapZoom,
    required this.rotateMap,
    required this.activeCheckList,
    required this.availableCheckLists,
    required this.listenOn,
    required this.headingBug,
    required this.altitudeBug,
    required this.increaseBug,
    required this.fixBug,
    required this.freeMap,
    required this.mapOffsetY,
    required this.mapOffsetX,
    required this.mapHeading,
    required this.lockedLatitude,
    required this.lockedLongitude,
    required this.mapBrightness,
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
    required this.airspaceZoom,
  });
}

class UiStateController {
  static StreamController<UiState> uiController = StreamController.broadcast();
  static UiState state = const UiState(
    overlayFirstPage: EfisPage.none,
    overlaySecondPage: EfisPage.none,
    firstPage: EfisPage.sixPack,
    secondPage: EfisPage.none,
    connected: true,
    flightOpen: false,
    mapZoom: 14,
    rotateMap: true,
    activeCheckList: '',
    availableCheckLists: [],
    listenOn: '',
    headingBug: 0,
    altitudeBug: 0,
    increaseBug: true,
    fixBug: true,
    freeMap: false,
    mapOffsetX: 0.0,
    mapOffsetY: 0.0,
    mapHeading: 0.0,
    lockedLatitude: 0.0,
    lockedLongitude: 0.0,
    mapBrightness: 0.0,
    visibleAirspaceClasses: {},
    visibleAirspaceTypes: {},
    showAirspaceLabels: true,
    showNavAids: true,
    showReportingPoints: true,
    showAirports: true,
    showAirspaces: true,
    showParachuteJumpZones: true,
    minAirspaceAlt: 0,
    maxAirspaceAlt: 40000,
    airspaceZoom: 5,
  );
  static Stream<UiState> get stream => uiController.stream;
  static void setFirstPage(EfisPage page) {
    state = state.copyWith(
      firstPage: page,
      overlayFirstPage: EfisPage.none,
    );
    uiController.add(state);
  }

  static void setSecondPage(EfisPage page) {
    state = state.copyWith(
      secondPage: page,
      overlaySecondPage: EfisPage.none,
    );
    uiController.add(state);
  }

  static void overlayFirstPage(EfisPage page) {
    state = state.copyWith(
      overlayFirstPage: page,
    );
    uiController.add(state);
  }

  static void overlaySecondPage(EfisPage page) {
    state = state.copyWith(
      overlaySecondPage: page,
    );
    uiController.add(state);
  }

  static void swapPages() {
    state = state.copyWith(
      firstPage: state.secondPage,
      overlayFirstPage: state.overlaySecondPage,
      secondPage: state.firstPage,
      overlaySecondPage: state.overlaySecondPage,
    );
    uiController.add(state);
  }

  static void setEfisPage(EfisPage function, SelectedPage page) {
    switch (page) {
      case SelectedPage.first:
        setFirstPage(function);
        break;
      case SelectedPage.second:
        setSecondPage(function);
        break;
    }
  }

  static void setConnectedState(bool connected) {
    if (connected == state.connected) {
      return;
    }
    state = state.copyWith(connected: connected);
    uiController.add(state);
  }

  static void setLogbookStatus(bool open) {
    state = state.copyWith(flightOpen: open);
    uiController.add(state);
  }

  static void setMapZoom(int mapZoom) {
    int oldZoom = state.mapZoom;
    double newMapOffsetX = state.mapOffsetX;
    double newMapOffsetY = state.mapOffsetY;
    while (oldZoom < mapZoom) {
      oldZoom++;
      newMapOffsetX = newMapOffsetX * 2.0;
      newMapOffsetY = newMapOffsetY * 2.0;
    }
    while (oldZoom > mapZoom) {
      oldZoom--;
      newMapOffsetX = newMapOffsetX / 2.0;
      newMapOffsetY = newMapOffsetY / 2.0;
    }
    state = state.copyWith(
      mapZoom: mapZoom,
      mapOffsetX: newMapOffsetX,
      mapOffsetY: newMapOffsetY,
    );
    uiController.add(state);
  }

  static void toggleRotateMap() {
    state = state.copyWith(rotateMap: !state.rotateMap);
    uiController.add(state);
  }

  static void setChecklist(String checklist) {
    state = state.copyWith(activeCheckList: checklist);
    uiController.add(state);
  }

  static void setAvailableCheckLists(List<String> available) {
    state = state.copyWith(availableCheckLists: available);
    uiController.add(state);
  }

  static void setListenOn(String listenOn) {
    state = state.copyWith(listenOn: listenOn);
    uiController.add(state);
  }

  static void setAltitudeBug(int altitude) {
    if (altitude < 0) {
      altitude = 0;
    }
    if (altitude > 100000) {
      altitude = 100000;
    }
    state = state.copyWith(altitudeBug: altitude);
    uiController.add(state);
  }

  static void setHeadingBug(int heading) {
    while (heading < 0) {
      heading = heading + 360;
    }
    while (heading >= 360) {
      heading = heading - 360;
    }
    state = state.copyWith(headingBug: heading);
    uiController.add(state);
  }

  static void setIncreaseBug(bool increase, {required bool fix}) {
    state = state.copyWith(increaseBug: increase, fixBug: fix);
    uiController.add(state);
  }

  static void resetMap() {
    state = state.copyWith(
      freeMap: false,
      rotateMap: true,
      mapOffsetY: 0.0,
      mapOffsetX: 0.0,
      mapHeading: 0.0,
      lockedLongitude: 0.0,
      lockedLatitude: 0.0,
    );
    uiController.add(state);
  }

  static void zoomMapToPosition(double latitude, double longitude) {
    state = state.copyWith(
      freeMap: true,
      rotateMap: false,
      mapOffsetY: 0.0,
      mapOffsetX: 0.0,
      mapHeading: 0.0,
      lockedLongitude: longitude,
      lockedLatitude: latitude,
    );
    uiController.add(state);
  }

  static void startPanMap(
    double heading,
    double latitude,
    double longitude,
  ) {
    if (state.freeMap) {
      state = state.copyWith(
        freeMap: true,
      );
    } else {
      state = state.copyWith(
        mapHeading: heading,
        freeMap: true,
        lockedLatitude: latitude,
        lockedLongitude: longitude,
      );
    }
    uiController.add(state);
  }

  static void updatePanMap(
    double mapOffsetX,
    double mapOffsetY,
  ) {
    state = state.copyWith(
      mapOffsetX: mapOffsetX,
      mapOffsetY: mapOffsetY,
    );
    uiController.add(state);
  }

  static void setMapBrightness(double brightness) {
    if (brightness > 1.0) {
      brightness = 1.0;
    }
    if (brightness < -1.0) {
      brightness = -1.0;
    }
    state = state.copyWith(
      mapBrightness: brightness,
    );
    uiController.add(state);
  }

  static void setMapAirspaceTypeVisible(AirspaceType type, bool visible) {
    Map<AirspaceType, bool> newMap = Map.from(state.visibleAirspaceTypes);
    newMap[type] = visible;
    state = state.copyWith(
      visibleAirspaceTypes: newMap,
    );
    uiController.add(state);
  }

  static void setMapAirspaceClassVisible(IcaoClass type, bool visible) {
    Map<IcaoClass, bool> newMap = Map.from(state.visibleAirspaceClasses);
    newMap[type] = visible;
    state = state.copyWith(
      visibleAirspaceClasses: newMap,
    );
    uiController.add(state);
  }

  static void showAirspaceLabels(bool visible) {
    state = state.copyWith(
      showAirspaceLabels: visible,
    );
    uiController.add(state);
  }

  static void showNavAids(bool visible) {
    state = state.copyWith(
      showNavAids: visible,
    );
    uiController.add(state);
  }

  static void showReportingPoints(bool visible) {
    state = state.copyWith(
      showReportingPoints: visible,
    );
    uiController.add(state);
  }

  static void showAirports(bool visible) {
    state = state.copyWith(
      showAirports: visible,
    );
    uiController.add(state);
  }

  static void showAirspaces(bool visible) {
    state = state.copyWith(
      showAirspaces: visible,
    );
    uiController.add(state);
  }

  static void showParachuteJumpZones(bool visible) {
    state = state.copyWith(
      showParachuteJumpZones: visible,
    );
    uiController.add(state);
  }

  static void setAirspaceRange(int min, int max) {
    state = state.copyWith(
      minAirspaceAlt: min,
      maxAirspaceAlt: max,
    );
    uiController.add(state);
  }

  static void setAirspaceZoom(int zoom) {
    state = state.copyWith(
      airspaceZoom: zoom,
    );
    uiController.add(state);
  }
}
