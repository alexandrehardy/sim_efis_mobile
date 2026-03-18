import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/label_check_box.dart';
import 'package:sim_efis/widgets/stateful_slider.dart';

class MapSettingsScreen extends StatefulWidget {
  final SelectedPage page;
  const MapSettingsScreen({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  State<MapSettingsScreen> createState() => _MapSettingsScreenState();
}

class _MapSettingsScreenState extends State<MapSettingsScreen> {
  @override
  void initState() {
    super.initState();
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
        if (widget.page == SelectedPage.first) {
          UiStateController.overlayFirstPage(EfisPage.none);
        } else {
          UiStateController.overlaySecondPage(EfisPage.none);
        }
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

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leftButton,
              const Text(
                'Map settings',
                style: EfisStyle.settingsTextStyle,
              ),
              rightButton,
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Brightness:',
                        style: EfisStyle.settingsTextStyle,
                      ),
                      SizedBox(
                        width: 200,
                        child: StatefulSlider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white,
                          thumbColor: Colors.white,
                          min: 0.5,
                          max: 1.5,
                          value: UiStateController.state.mapBrightness + 1.0,
                          onChanged: (value) {
                            UiStateController.setMapBrightness(value - 1.0);
                          },
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show airspaces',
                        value: snapshot.requireData.showAirspaces,
                        onChanged: (bool value) {
                          UiStateController.showAirspaces(value);
                        },
                      );
                    },
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show airspace names',
                        value: snapshot.requireData.showAirspaceLabels,
                        onChanged: (bool value) {
                          UiStateController.showAirspaceLabels(value);
                        },
                      );
                    },
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show airports',
                        value: snapshot.requireData.showAirports,
                        onChanged: (bool value) {
                          UiStateController.showAirports(value);
                        },
                      );
                    },
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show Nav Aids',
                        value: snapshot.requireData.showNavAids,
                        onChanged: (bool value) {
                          UiStateController.showNavAids(value);
                        },
                      );
                    },
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show reporting points',
                        value: snapshot.requireData.showReportingPoints,
                        onChanged: (bool value) {
                          UiStateController.showReportingPoints(value);
                        },
                      );
                    },
                  ),
                  StreamBuilder<UiState>(
                    initialData: UiStateController.state,
                    stream: UiStateController.stream,
                    builder: (BuildContext context, snapshot) {
                      return LabelCheckbox(
                        label: 'Show parachute zones',
                        value: snapshot.requireData.showParachuteJumpZones,
                        onChanged: (bool value) {
                          UiStateController.showParachuteJumpZones(value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Min Alt:',
                          style: EfisStyle.settingsTextStyle,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: SliderTheme(
                          data: const SliderThemeData(
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: StatefulSlider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.white,
                            thumbColor: Colors.white,
                            min: 0,
                            max: 40000,
                            value: UiStateController.state.minAirspaceAlt
                                .toDouble(),
                            label: '${UiStateController.state.minAirspaceAlt}',
                            onChanged: (value) {
                              UiStateController.setAirspaceRange(
                                value.toInt(),
                                UiStateController.state.maxAirspaceAlt,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Max Alt:',
                          style: EfisStyle.settingsTextStyle,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: SliderTheme(
                          data: const SliderThemeData(
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: StatefulSlider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.white,
                            thumbColor: Colors.white,
                            min: 0,
                            max: 40000,
                            value: UiStateController.state.maxAirspaceAlt
                                .toDouble(),
                            label: '${UiStateController.state.maxAirspaceAlt}',
                            onChanged: (value) {
                              UiStateController.setAirspaceRange(
                                UiStateController.state.minAirspaceAlt,
                                value.toInt(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StreamBuilder<UiState>(
                        initialData: UiStateController.state,
                        stream: UiStateController.stream,
                        builder: (BuildContext context, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Airspace types',
                                style: EfisStyle.settingsTextStyle,
                              ),
                              ...AirspaceType.values
                                  .map(
                                    (e) => LabelCheckbox(
                                      label: e.name,
                                      value: snapshot.requireData
                                              .visibleAirspaceTypes[e] ??
                                          true,
                                      onChanged: (bool value) {
                                        UiStateController
                                            .setMapAirspaceTypeVisible(
                                          e,
                                          value,
                                        );
                                      },
                                    ),
                                  ),
                            ],
                          );
                        },
                      ),
                      StreamBuilder<UiState>(
                        initialData: UiStateController.state,
                        stream: UiStateController.stream,
                        builder: (BuildContext context, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Airspace class:',
                                style: EfisStyle.settingsTextStyle,
                              ),
                              ...IcaoClass.values
                                  .map(
                                    (e) => LabelCheckbox(
                                      label: e.name,
                                      value: snapshot.requireData
                                              .visibleAirspaceClasses[e] ??
                                          true,
                                      onChanged: (bool value) {
                                        UiStateController
                                            .setMapAirspaceClassVisible(
                                          e,
                                          value,
                                        );
                                      },
                                    ),
                                  ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
