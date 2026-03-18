import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/vector.dart';
import 'package:sim_efis/widgets/compass_rotation.dart';
import 'package:sim_efis/widgets/efis_tab.dart';

class AirportDetailScreen extends StatefulWidget {
  final SelectedPage page;
  final Airport airport;
  final VoidCallback onClose;
  final double initialHeading;
  final double initialDistance;
  const AirportDetailScreen({
    Key? key,
    required this.page,
    required this.onClose,
    required this.airport,
    required this.initialHeading,
    required this.initialDistance,
  }) : super(key: key);

  @override
  State<AirportDetailScreen> createState() => _AirportDetailScreenState();
}

class _AirportDetailScreenState extends State<AirportDetailScreen> {
  int selected = 0;
  double distance = 0.0;
  double heading = 0.0;
  double trueHeading = 0.0;
  Timer? updateDirectionTimer;
  CompassController? _controller;

  @override
  void initState() {
    super.initState();
    heading = widget.initialHeading;
    distance = widget.initialDistance;
    widget.airport.frequencies
        .sort((a, b) => a.type.name.compareTo(b.type.name));
    _controller = CompassController();
    computeDirection();
    updateDirectionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        computeDirection();
      },
    );
  }

  @override
  void dispose() {
    updateDirectionTimer?.cancel();
    super.dispose();
  }

  void computeDirection() {
    double latitude = InstrumentDataStream.instance.currentUI.latitude;
    double longitude = InstrumentDataStream.instance.currentUI.longitude;
    Vector ref = Vector.from(
      latitude: latitude,
      longitude: longitude,
    );
    Vector airportPos = Vector.from(
      latitude: widget.airport.location.latitude,
      longitude: widget.airport.location.longitude,
    );
    double newDistance = ref.angleAlreadyNormal(airportPos) * 3443.92;
    double newTrueHeading = ref.heading(airportPos);
    double newHeading = newTrueHeading -
        ((UiStateController.state.rotateMap)
            ? InstrumentDataStream.instance.currentUI.trueHeading
            : 0.0);

    if (mounted) {
      setState(() {
        distance = newDistance;
        heading = newHeading;
        trueHeading = newTrueHeading;
      });
      _controller!.setHeading(heading);
    }
  }

  Widget runway(Runway r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(r.designator, style: EfisStyle.settingsTextStyle),
        ),
        SizedBox(
          width: 150,
          child: Text(
            '${r.length}m x ${r.width}m',
            style: EfisStyle.settingsTextStyle,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(r.turnDirection.name, style: EfisStyle.settingsTextStyle),
        ),
        SizedBox(
          width: 80,
          child:
              Text(r.mainRunway ? 'Y' : '', style: EfisStyle.settingsTextStyle),
        ),
      ],
    );
  }

  Widget runwayScreen() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Text('RWY', style: EfisStyle.settingsTextStyle),
            ),
            SizedBox(
              width: 150,
              child: Text('Dimension', style: EfisStyle.settingsTextStyle),
            ),
            SizedBox(
              width: 80,
              child: Text('Circuit', style: EfisStyle.settingsTextStyle),
            ),
            SizedBox(
              width: 80,
              child: Text('Main', style: EfisStyle.settingsTextStyle),
            ),
          ],
        ),
        const Divider(
          color: Colors.white,
          thickness: 3,
        ),
        ...widget.airport.runways.map((e) => runway(e)),
      ],
    );
  }

  Widget frequency(Frequency f) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(f.type.name, style: EfisStyle.settingsTextStyle),
        ),
        SizedBox(
          width: 150,
          child: Text('${f.value} MHz', style: EfisStyle.settingsTextStyle),
        ),
      ],
    );
  }

  Widget frequencyScreen() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text('Name', style: EfisStyle.settingsTextStyle),
            ),
            SizedBox(
              width: 150,
              child: Text('Frequency', style: EfisStyle.settingsTextStyle),
            ),
          ],
        ),
        const Divider(
          color: Colors.white,
          thickness: 3,
        ),
        ...widget.airport.frequencies.map((e) => frequency(e)),
      ],
    );
  }

  Widget imagesScreen() {
    return Column(
      children: [
        ...widget.airport.images.map((e) => Image.network(
              AirspaceCache.getAirportImageUrl(e),
              headers: AirspaceCache.getImageRequestHeaders(),
            )),
      ],
    );
  }

  Widget infoScreen() {
    double displayDist = (distance * 10).roundToDouble() / 10.0;
    double displayLatitude =
        (widget.airport.location.latitude * 100).roundToDouble() / 100.0;
    String latitudeText =
        (displayLatitude < 0) ? '${-displayLatitude} S' : '$displayLatitude N';
    double displayLongitude =
        (widget.airport.location.longitude * 100).roundToDouble() / 100.0;
    String longitudeText = (displayLongitude < 0)
        ? '${-displayLongitude} W'
        : '$displayLongitude E';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 150,
              child: Text(
                'Distance: ',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            Text(
              '$displayDist nm',
              style: EfisStyle.settingsTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(
              width: 150,
              child: Text(
                'Heading(T): ',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '${trueHeading.round()}',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            CompassRotation(
              initialHeading: widget.initialHeading,
              controller: _controller!,
              child: const Icon(
                CupertinoIcons.location_north_fill,
                size: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        'Latitude: ',
                        style: EfisStyle.settingsTextStyle,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        latitudeText,
                        style: EfisStyle.settingsTextStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        'Longitude: ',
                        style: EfisStyle.settingsTextStyle,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        longitudeText,
                        style: EfisStyle.settingsTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              child: const Icon(
                Icons.location_pin,
                size: 32,
                color: Colors.white,
              ),
              onTap: () {
                UiStateController.zoomMapToPosition(
                  widget.airport.location.latitude,
                  widget.airport.location.longitude,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 150,
              child: Text(
                'Elevation: ',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            Text(
              '${widget.airport.elevation.toInt()} ft',
              style: EfisStyle.settingsTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget buildSelectedScreen() {
    switch (selected) {
      case 0:
        return infoScreen();
      case 1:
        return runwayScreen();
      case 2:
        return frequencyScreen();
      case 3:
        return imagesScreen();
      default:
        return runwayScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget closeButton = IconButton(
      iconSize: 40,
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        widget.onClose();
      },
    );

    Widget leftButton;
    Widget rightButton;
    if (Settings.landscapeMode) {
      if (widget.page == SelectedPage.first) {
        leftButton = const SizedBox(width: 32);
        rightButton = closeButton;
      } else {
        rightButton = const SizedBox(width: 32);
        leftButton = closeButton;
      }
    } else {
      rightButton = const SizedBox(width: 32);
      leftButton = closeButton;
    }

    return DefaultTabController(
      length: (widget.airport.images.isEmpty) ? 3 : 4,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leftButton,
                Text(
                  widget.airport.name +
                      ((widget.airport.icaoCode != null)
                          ? ' (${widget.airport.icaoCode})'
                          : ''),
                  style: EfisStyle.settingsTextStyle,
                ),
                rightButton,
              ],
            ),
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
                    text: 'Info',
                    align: TextAlign.center,
                    selected: 0 == selected,
                  ),
                ),
                Tab(
                  child: EfisTab(
                    text: 'Runways',
                    align: TextAlign.center,
                    selected: 1 == selected,
                  ),
                ),
                Tab(
                  child: EfisTab(
                    text: 'Radio',
                    align: TextAlign.center,
                    selected: 2 == selected,
                  ),
                ),
                if (widget.airport.images.isNotEmpty)
                  Tab(
                    child: EfisTab(
                      text: 'Images',
                      align: TextAlign.center,
                      selected: 3 == selected,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: buildSelectedScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
