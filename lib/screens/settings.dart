import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/screens/config_help.dart';
import 'package:sim_efis/screens/export_checklist_screen.dart';
import 'package:sim_efis/screens/export_limits_screen.dart';
import 'package:sim_efis/screens/import_checklist_screen.dart';
import 'package:sim_efis/screens/import_limits_screen.dart';
import 'package:sim_efis/screens/log_screen.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/tile_cache.dart';
import 'package:sim_efis/widgets/check_list_item.dart';
import 'package:sim_efis/widgets/dropdown_radio.dart';
import 'package:sim_efis/widgets/floating_button.dart';
import 'package:sim_efis/widgets/network_selector.dart';
import 'package:sim_efis/widgets/settings_button.dart';
import 'package:sim_efis/widgets/text_with_default.dart';

class SimulatorSelector extends StatefulWidget {
  final VoidCallback onChange;
  const SimulatorSelector({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<SimulatorSelector> createState() => _SimulatorSelectorState();
}

class _SimulatorSelectorState extends State<SimulatorSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropDownRadioWidget(
          title: 'SIMULATOR',
          settings: const [
            'None',
            'This Device',
            'IL2-1946',
            'X-Plane',
            'FlightGear',
            'DCS',
            'Microsoft Flight Simulator 2020',
            'Random data'
          ],
          selected: Settings.simulatorString(Settings.simulator),
          onChanged: (value) {
            setState(() {
              if (value == 'None') {
                Settings.simulator = Simulator.None;
              }
              if (value == 'This Device') {
                Settings.simulator = Simulator.ThisDevice;
              }
              if (value == 'IL2-1946') {
                Settings.simulator = Simulator.IL2_1946;
              }
              if (value == 'X-Plane') {
                Settings.simulator = Simulator.XPlane;
              }
              if (value == 'FlightGear') {
                Settings.simulator = Simulator.FlightGear;
              }
              if (value == 'DCS') {
                Settings.simulator = Simulator.DCS;
              }
              if (value == 'Microsoft Flight Simulator 2020') {
                Settings.simulator = Simulator.MSFS2020;
              }
              if (value == 'Random data') {
                Settings.simulator = Simulator.Random;
              }
              widget.onChange();
            });
          },
        ),
        const SizedBox(height: 30.0),
        const Text('SIMULATOR SETUP:'),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: FutureBuilder(
            future: Settings.helpForSimulator(context, Settings.simulator),
            initialData: '',
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                Text(snapshot.requireData),
          ),
        ),
        SettingsButton(
          label: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Center(
              child: Text(
                'DETAILED CONFIGURATION',
                style: EfisStyle.efisPageButtonStyle,
              ),
            ),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    ConfigHelpScreen(simulator: Settings.simulator),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController portController = TextEditingController(text: '');
  String mapSize = '...';
  String airspaceSize = '...';

  @override
  void initState() {
    super.initState();
    computeMapSize();
    computeAirspaceSize();
  }

  @override
  void dispose() {
    portController.dispose();
    super.dispose();
  }

  String sizeToHuman(int size) {
    if (size > 1024 * 1024 * 1024) {
      int sizeGb = size * 10 ~/ 1024 ~/ 1024 ~/ 1024;
      int major = sizeGb ~/ 10;
      int minor = sizeGb - major * 10;
      return '$major.$minor Gb';
    } else if (size > 1024 * 1024) {
      int sizeMb = size * 10 ~/ 1024 ~/ 1024;
      int major = sizeMb ~/ 10;
      int minor = sizeMb - major * 10;
      return '$major.$minor Mb';
    } else if (size > 1024) {
      int sizeKb = size * 10 ~/ 1024;
      int major = sizeKb ~/ 10;
      int minor = sizeKb - major * 10;
      return '$major.$minor Kb';
    } else {
      return '$size';
    }
  }

  void computeMapSize() async {
    int size = await TileDiskCache.getDiskTileSpace();
    String humanSize = sizeToHuman(size);
    if (mounted) {
      setState(() {
        mapSize = humanSize;
      });
    }
  }

  void computeAirspaceSize() async {
    int size = await AirspaceCache.getDiskSpace();
    String humanSize = sizeToHuman(size);
    if (mounted) {
      setState(() {
        airspaceSize = humanSize;
      });
    }
  }

  bool isInternetAddress(String value) {
    InternetAddress? address = InternetAddress.tryParse(value);
    if (address == null) {
      return false;
    }
    // TODO: Support IPv6?
    return address.type == InternetAddressType.IPv4;
  }

  String filterString(FilterQuality setting) {
    switch (setting) {
      case FilterQuality.none:
        return 'None';
      case FilterQuality.low:
        return 'Low';
      case FilterQuality.medium:
        return 'Medium';
      case FilterQuality.high:
        return 'High';
      default:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget form = Container(
      padding: const EdgeInsets.all(10.0),
      color: EfisColors.backgroundDark,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SimulatorSelector(
              onChange: () {
                int port = NetworkPorts.defaultPorts[Settings.simulator] ?? 0;
                Settings.port = port;
                portController.text = '$port';
              },
            ),
            const SizedBox(height: 30.0),
            const NetworkSelector(),
            const SizedBox(height: 30.0),
            const Text('SIMULATOR DETAILS:'),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextWithDefault(
                keyboardType: (Platform.isAndroid)
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : null,
                label: 'HOST:',
                onChanged: (String value) {
                  if (isInternetAddress(value)) {
                    Settings.connectTo = value;
                    return true;
                  }
                  return false;
                },
                onDefault: () async {
                  String subnet = await getSubnetString();
                  Settings.connectTo = subnet;
                  return subnet;
                },
                text: Settings.connectTo,
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextWithDefault(
                controller: portController,
                keyboardType:
                    (Platform.isAndroid) ? TextInputType.number : null,
                label: 'PORT:',
                onChanged: (String value) {
                  int? port = int.tryParse(value);
                  if (port == null) {
                    return false;
                  }
                  if (port < 0) {
                    return false;
                  }
                  if (port > 65535) {
                    return false;
                  }
                  Settings.port = port;
                  return true;
                },
                onDefault: () async {
                  int port = NetworkPorts.defaultPorts[Settings.simulator] ?? 0;
                  Settings.port = port;
                  return '$port';
                },
                text: '${Settings.port ?? 0}',
              ),
            ),
            const SizedBox(height: 20.0),
            StreamBuilder<UiState>(
              stream: UiStateController.stream,
              initialData: UiStateController.state,
              builder: (context, snapshot) {
                if (snapshot.requireData.listenOn.isEmpty) {
                  return Container();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LISTENING ON:'),
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Text(snapshot.requireData.listenOn),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30.0),
            const Text('AIRCRAFT CONFIGURATION:'),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'IMPORT AIRCRAFT',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ImportAircraftLimitsScreen(),
                  ),
                );
              },
            ),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'EXPORT AIRCRAFT',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                NavigatorState navigator = Navigator.of(context);
                List<String> options = await Settings.loadableAircraftParams();
                await navigator.push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ExportAircraftLimitsScreen(
                      options: options,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30.0),
            const Text('CHECKLISTS:'),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'IMPORT CHECKLISTS',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ImportCheckListScreen(),
                  ),
                );
              },
            ),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'EXPORT CHECKLISTS',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                NavigatorState navigator = Navigator.of(context);
                await Settings.loadAvailableChecklists();
                List<CheckList> options = [];
                for (CheckList c in Settings.checkLists.values) {
                  options.add(c);
                }
                await navigator.push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ExportCheckListScreen(
                      options: options,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30.0),
            const Text('MAP:'),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data: © OpenStreetMap contributors, SRTM'),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'www.openstreetmap.org',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Style: © OpenTopoMap (CC-BY-SA)'),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'www.opentopomap.org',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text('Space used: $mapSize'),
                  const SizedBox(height: 10.0),
                  Text('Map memory limit: ${Settings.maxMapMemory} Mb'),
                  const SizedBox(height: 10.0),
                  Text('Map storage limit: ${Settings.maxMapDisk} Mb'),
                ],
              ),
            ),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'CLEAR MAP CACHE',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                await TileDiskCache.clearCache();
                computeMapSize();
              },
            ),
            const SizedBox(height: 30.0),
            const Text('AIRSPACE:'),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data: OpenAIP'),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'www.openaip.net',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text('Space used: $airspaceSize'),
                ],
              ),
            ),
            SettingsButton(
              label: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: Text(
                    'CLEAR AIRSPACE DATA',
                    style: EfisStyle.efisPageButtonStyle,
                  ),
                ),
              ),
              onPressed: () async {
                await AirspaceCache.clearCache();
              },
            ),
            const SizedBox(height: 30),
            DropDownRadioWidget(
              title: 'FILTER QUALITY',
              description: 'Higher filter quality improves the readability '
                  'of instruments, but consumes more battery power '
                  'and may also make instruments slow to respond.',
              settings: const [
                'None',
                'Low',
                'Medium',
                'High',
              ],
              selected: filterString(Settings.filterQuality),
              onChanged: (String value) {
                if (value == 'None') {
                  Settings.filterQuality = FilterQuality.none;
                }
                if (value == 'Low') {
                  Settings.filterQuality = FilterQuality.low;
                }
                if (value == 'Medium') {
                  Settings.filterQuality = FilterQuality.medium;
                }
                if (value == 'High') {
                  Settings.filterQuality = FilterQuality.high;
                }
                // TODO: Save this in persistent settings, and load it.
              },
            ),
          ],
        ),
      ),
    );
    return PopScope(
      onPopInvoked: (bool didPop) {
        Settings.applySettings();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('SETTINGS'),
            ],
          ),
          backgroundColor: EfisColors.background,
          actions: [
            FloatingButton(
              onPressed: () {
                Settings.applySettings();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const LogScreen(),
                  ),
                );
              },
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'LOGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverList(delegate: SliverChildListDelegate([form])),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: <Widget>[
                    Container(height: 200.0, color: Colors.black45),
                    Expanded(child: Container(color: Colors.black45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
