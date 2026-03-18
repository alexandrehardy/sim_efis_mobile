import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/map/map_painter.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/tile_cache.dart';
import 'package:sim_efis/vector.dart';
import 'package:sim_efis/widgets/airspace_card.dart';
import 'package:sim_efis/widgets/efis_tab.dart';
import 'package:sim_efis/widgets/ensure_data_feed.dart';

class AirspaceListScreen extends StatefulWidget {
  const AirspaceListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AirspaceListScreen> createState() => _AirspaceListScreenState();
}

class AirspaceWithDistance {
  final Airspace airspace;
  final double distance; // nautical mile
  final double trueHeading;

  const AirspaceWithDistance({
    required this.airspace,
    required this.distance,
    required this.trueHeading,
  });
}

class _AirspaceListScreenState extends State<AirspaceListScreen> {
  int selected = 0;
  List<AirspaceWithDistance> airspaces = [];
  Timer? fetchAirspaceTimer;

  @override
  void initState() {
    super.initState();
    getAirspaces();
    fetchAirspaceTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) {
        getAirspaces();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    fetchAirspaceTimer?.cancel();
  }

  AirspaceWithDistance makeAirspaceInfo(
    Airspace airspace,
    Vector ref,
  ) {
    Vector airspacePos = Vector.from(
      latitude: airspace.centre.latitude,
      longitude: airspace.centre.longitude,
    );
    double distance = ref.angleAlreadyNormal(airspacePos) * 3443.92;

    return AirspaceWithDistance(
      airspace: airspace,
      distance: distance,
      trueHeading: ref.heading(airspacePos),
    );
  }

  int sortByDistance(AirspaceWithDistance a, AirspaceWithDistance b) {
    int distanceCompare = a.distance.compareTo(b.distance);
    if (distanceCompare != 0) {
      return distanceCompare;
    }
    return a.airspace.name.compareTo(b.airspace.name);
  }

  void getAirspaces() {
    double latitude = InstrumentDataStream.instance.currentUI.latitude;
    double longitude = InstrumentDataStream.instance.currentUI.longitude;
    if (selected == 1) {
      if (UiStateController.state.freeMap) {
        latitude = UiStateController.state.lockedLatitude;
        longitude = UiStateController.state.lockedLongitude;
      }
      Tile tile = MapPainter.tileFor(
        latitude: latitude,
        longitude: longitude,
        mapOffsetX: UiStateController.state.mapOffsetX,
        mapOffsetY: UiStateController.state.mapOffsetY,
        zoom: UiStateController.state.mapZoom,
      );
      latitude = MapPainter.tileLatitude(tile);
      longitude = MapPainter.tileLongitude(tile);
    }
    Vector ref = Vector.from(
      latitude: latitude,
      longitude: longitude,
    );

    List<Airspace> airspaceList = AirspaceCache.getAirspaces(
      minLatitude: (latitude - 1.0),
      maxLatitude: (latitude + 1.0),
      minLongitude: (longitude - 1.0),
      maxLongitude: (longitude + 1.0),
      zoom: 14,
    );

    List<AirspaceWithDistance> newAirspaces = airspaceList
        .map((e) => makeAirspaceInfo(e, ref))
        .toList()
      ..sort(sortByDistance);
    if (mounted) {
      setState(() {
        airspaces = newAirspaces.take(100).toList();
      });
    }
  }

  Widget buildList(BuildContext context) {
    if (airspaces.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(
              Colors.white,
            ),
          ),
        ),
      );
    }
    return ListView(
      children: airspaces
          .map((e) => AirspaceCard(
                key: ValueKey(e.airspace.name),
                airspace: e.airspace,
                distance: e.distance,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnsureDataFeed(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Nearest Air Spaces',
              style: EfisStyle.settingsTextStyle,
            ),
            const SizedBox(height: 10),
            TabBar(
              indicatorColor: Colors.grey,
              onTap: (int index) {
                if (mounted) {
                  setState(() {
                    selected = index;
                  });
                }
              },
              tabs: [
                Tab(
                  child: EfisTab(
                    text: 'To aircraft',
                    align: TextAlign.center,
                    selected: 0 == selected,
                  ),
                ),
                Tab(
                  child: EfisTab(
                    text: 'To map centre',
                    align: TextAlign.center,
                    selected: 1 == selected,
                  ),
                ),
              ],
            ),
            Expanded(child: buildList(context)),
          ],
        ),
      ),
    );
  }
}
