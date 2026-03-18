import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/map/map_painter.dart';
import 'package:sim_efis/screens/airport_detail_screen.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/tile_cache.dart';
import 'package:sim_efis/vector.dart';
import 'package:sim_efis/widgets/airport_card.dart';
import 'package:sim_efis/widgets/efis_tab.dart';
import 'package:sim_efis/widgets/ensure_data_feed.dart';

class AirportsScreen extends StatefulWidget {
  final SelectedPage page;
  const AirportsScreen({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  State<AirportsScreen> createState() => _AirportsScreenState();
}

class AirportWithDistance {
  final Airport airport;
  final double distance; // nautical mile
  final double trueHeading;

  const AirportWithDistance({
    required this.airport,
    required this.distance,
    required this.trueHeading,
  });
}

class _AirportsScreenState extends State<AirportsScreen> {
  int selected = 0;
  List<AirportWithDistance> airports = [];
  Timer? fetchAirportsTimer;
  AirportWithDistance? selectedAirport;

  @override
  void initState() {
    super.initState();
    getAirports();
    fetchAirportsTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        getAirports();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    fetchAirportsTimer?.cancel();
  }

  AirportWithDistance makeAirportInfo(
    Airport airport,
    Vector ref,
  ) {
    Vector airportPos = Vector.from(
      latitude: airport.location.latitude,
      longitude: airport.location.longitude,
    );
    double distance = ref.angleAlreadyNormal(airportPos) * 3443.92;

    return AirportWithDistance(
      airport: airport,
      distance: distance,
      trueHeading: ref.heading(airportPos),
    );
  }

  int sortByDistance(AirportWithDistance a, AirportWithDistance b) {
    int distanceCompare = a.distance.compareTo(b.distance);
    if (distanceCompare != 0) {
      return distanceCompare;
    }
    return a.airport.name.compareTo(b.airport.name);
  }

  void getAirports() {
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

    List<Airport> airportsList = AirspaceCache.getAirports(
      minLatitude: (latitude - 1.0),
      maxLatitude: (latitude + 1.0),
      minLongitude: (longitude - 1.0),
      maxLongitude: (longitude + 1.0),
      zoom: 14,
    );

    List<AirportWithDistance> newAirports = airportsList
        .map((e) => makeAirportInfo(e, ref))
        .toList()
      ..sort(sortByDistance);
    if (mounted) {
      setState(() {
        airports = newAirports.take(10).toList();
      });
    }
  }

  void selectAirport(Airport airport) {
    double latitude = InstrumentDataStream.instance.currentUI.latitude;
    double longitude = InstrumentDataStream.instance.currentUI.longitude;
    if (selected == 1) {
      // From map location
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
    selectedAirport = makeAirportInfo(airport, ref);
  }

  Widget buildList(BuildContext context) {
    double extraHeading = ((UiStateController.state.rotateMap)
        ? InstrumentDataStream.instance.currentUI.trueHeading
        : 0.0);

    if (airports.isEmpty) {
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
      children: airports
          .map((e) => AirportCard(
                key: ValueKey(e.airport.name),
                airport: e.airport,
                distance: e.distance,
                trueHeading: e.trueHeading - extraHeading,
                onInfoPressed: selectAirport,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedAirport != null) {
      return EnsureDataFeed(
        child: AirportDetailScreen(
          initialHeading: selectedAirport!.trueHeading,
          initialDistance: selectedAirport!.distance,
          airport: selectedAirport!.airport,
          page: widget.page,
          onClose: () {
            if (mounted) {
              setState(() {
                selectedAirport = null;
              });
            }
          },
        ),
      );
    }
    return EnsureDataFeed(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Nearest Airports',
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
