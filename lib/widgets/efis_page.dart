import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/aircraft_state.dart';
import 'package:sim_efis/screens/airports_screen.dart';
import 'package:sim_efis/screens/airspace_screen.dart';
import 'package:sim_efis/screens/analog_and_gear.dart';
import 'package:sim_efis/screens/analog_screen.dart';
import 'package:sim_efis/screens/analog_twelve.dart';
import 'package:sim_efis/screens/checklist_screen.dart';
import 'package:sim_efis/screens/efis_screen.dart';
import 'package:sim_efis/screens/engine_screen.dart';
import 'package:sim_efis/screens/flight_log_screen.dart';
import 'package:sim_efis/screens/map_screen.dart';
import 'package:sim_efis/screens/map_settings_screen.dart';
import 'package:sim_efis/screens/parameters_screen.dart';
import 'package:sim_efis/screens/selector_screen.dart';

class EfisPageWidget extends StatelessWidget {
  static Key firstGlobalKey = GlobalKey();
  static Key secondGlobalKey = GlobalKey();
  static Key firstOverlayKey = GlobalKey();
  static Key secondOverlayKey = GlobalKey();
  final EfisPage function;
  final EfisPage overlay;
  final SelectedPage page;

  const EfisPageWidget({
    Key? key,
    required this.function,
    required this.overlay,
    required this.page,
  }) : super(key: key);

  Widget screenForPage(Key key, EfisPage function) {
    switch (function) {
      case EfisPage.sixPack:
        return SixPackScreen(key: key);
      case EfisPage.primaryFlightDisplay:
        return EfisScreen(key: key);
      case EfisPage.engine:
        return EngineScreen(key: key);
      case EfisPage.checklist:
        return ChecklistScreen(key: key);
      case EfisPage.flightLog:
        return FlightLogScreen(key: key);
      case EfisPage.params:
        return ParametersScreen(key: key);
      case EfisPage.map:
        return MapScreen(key: key);
      case EfisPage.selector:
        return SelectorScreen(key: key, page: page);
      case EfisPage.gear:
        return AircraftStateInstruments(
          key: key,
          backgroundColor: EfisColors.background,
        );
      case EfisPage.ninePack:
        return NinePackScreen(key: key);
      case EfisPage.twelvePack:
        return TwelvePackScreen(key: key);
      case EfisPage.none:
        return Container(key: key);
      case EfisPage.mapSettings:
        return MapSettingsScreen(key: key, page: page);
      case EfisPage.airports:
        return AirportsScreen(key: key, page: page);
      case EfisPage.airspace:
        return AirspaceScreen(
          key: key,
        );
      default:
        return Container(
          key: key,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Key key;
    Key overlayKey;
    Widget screen;
    Widget overlayScreen;

    switch (page) {
      case SelectedPage.first:
        key = firstGlobalKey;
        overlayKey = firstOverlayKey;
        break;
      case SelectedPage.second:
        key = secondGlobalKey;
        overlayKey = secondOverlayKey;
        break;
    }

    screen = screenForPage(key, function);
    if (overlay == EfisPage.none) {
      return screen;
    }
    overlayScreen = screenForPage(overlayKey, overlay);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 0,
          height: 0,
          child: Offstage(child: screen),
        ),
        Expanded(child: overlayScreen),
      ],
    );
  }
}
