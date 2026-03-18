//ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/plugins/dcs.dart';
import 'package:sim_efis/data/plugins/device_link.dart';
import 'package:sim_efis/data/plugins/empty.dart';
import 'package:sim_efis/data/plugins/msfs.dart';
import 'package:sim_efis/data/plugins/random.dart';
import 'package:sim_efis/data/plugins/sim_efis_active.dart';
import 'package:sim_efis/data/plugins/sim_efis_passive.dart';
import 'package:sim_efis/data/plugins/this_device.dart';
import 'package:sim_efis/data/plugins/xplane.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/widgets/check_list_item.dart';

enum Simulator {
  None,
  IL2_1946,
  XPlane,
  FlightGear,
  DCS,
  MSFS2020,
  Random,
  ThisDevice,
}

enum Driver {
  DCS,
  DeviceLink,
  MSFS2020,
  Random,
  SimEfisActive,
  SimEfisPassive,
  XPlane,
  Empty,
  ThisDevice,
}

Map<Simulator, Driver> driverMap = {
  Simulator.None: Driver.Empty,
  Simulator.IL2_1946: Driver.DeviceLink,
  Simulator.XPlane: Driver.XPlane,
  Simulator.FlightGear: Driver.SimEfisPassive,
  Simulator.DCS: Driver.DCS,
  Simulator.MSFS2020: Driver.MSFS2020,
  Simulator.Random: Driver.Random,
  Simulator.ThisDevice: Driver.ThisDevice,
};

class Settings {
  static bool _settingsApplied = false;
  static String _connectTo = '192.168.1.0';
  static String? _listenOn;
  static String listenInterface = 'All';
  static int? _port = 5000;
  static int maxMapMemory = 400; // 400 Mb
  static int maxMapDisk = 1000; // 1Gb
  static int averageMapPngSize = 50000;
  static int maxMapMemoryTiles =
      (maxMapMemory * 1024 * 1024 ~/ (256 * 256 * 4));
  static int maxMapDiskTiles =
      (maxMapDisk * 1024 * 1024 ~/ (averageMapPngSize));
  static Driver _driver = Driver.Empty;
  static Simulator _simulator = Simulator.None;
  static FilterQuality filterQuality = FilterQuality.low;
  static Simulator get simulator => _simulator;
  static Map<String, CheckList> checkLists = {};
  static bool landscapeMode = false;

  static InstrumentDataSourcePlugin pluginForDriver(Driver driver) {
    switch (driver) {
      case Driver.Empty:
        return EmptySourcePlugin();
      case Driver.Random:
        return RandomDataSourcePlugin();
      case Driver.DeviceLink:
        return DeviceLinkSourcePlugin();
      case Driver.SimEfisPassive:
        return SimEfisPassiveUDP();
      case Driver.SimEfisActive:
        return SimEfisActiveUDP();
      case Driver.DCS:
        return SimEfisDcsUDP();
      case Driver.XPlane:
        return XPlaneSourcePlugin();
      case Driver.MSFS2020:
        return MSFS2020SourcePlugin();
      case Driver.ThisDevice:
        return ThisDeviceDataSourcePlugin();
      default:
        return EmptySourcePlugin();
    }
  }

  static Future<String> helpForSimulator(
      BuildContext context, Simulator simulator) async {
    String address = Settings.listenOn ?? '192.168.1.1';
    int port = NetworkPorts.networkPorts[simulator] ?? 0;
    return (await DefaultAssetBundle.of(context).loadString(
            'assets/confighelp/short/sim_${_simulator.name.toLowerCase()}.txt'))
        .split('\n')
        .map((e) => e.trim())
        .join(' ')
        .replaceAll('{MyIP}', address)
        .replaceAll('{MyPort}', '$port');
  }

  static Future<String> configHelpForSimulator(
      BuildContext context, Simulator simulator) async {
    String address = Settings.listenOn ?? '192.168.1.1';
    int port = NetworkPorts.networkPorts[simulator] ?? 0;
    return (await DefaultAssetBundle.of(context).loadString(
            'assets/confighelp/sim_${_simulator.name.toLowerCase()}.md'))
        .replaceAll('{MyIP}', address)
        .replaceAll('{MyPort}', '$port');
  }

  static void applySettings() {
    if (_settingsApplied) return;
    InstrumentDataStream.instance.plugin = pluginForDriver(driver);
    _settingsApplied = true;
  }

  static void reconnect() {
    _settingsApplied = false;
    applySettings();
  }

  static set simulator(Simulator sim) {
    if (_simulator != sim) {
      _simulator = sim;
      _driver = driverMap[sim]!;
      _settingsApplied = false;
    }
  }

  static Driver get driver => _driver;

  static String get connectTo => _connectTo;
  static set connectTo(String value) {
    if (_connectTo != value) {
      _connectTo = value;
      _settingsApplied = false;
    }
  }

  static String? get listenOn => _listenOn;
  static set listenOn(String? value) {
    if (_listenOn != value) {
      _listenOn = value;
      _settingsApplied = false;
    }
  }

  static int? get port => _port;
  static set port(int? value) {
    if (_port != value) {
      _port = value;
      _settingsApplied = false;
    }
  }

  static String simulatorString(Simulator sim, {bool long = true}) {
    switch (sim) {
      case Simulator.None:
        return 'None';
      case Simulator.Random:
        return (long) ? 'Random data' : 'RND';
      case Simulator.DCS:
        return 'DCS';
      case Simulator.FlightGear:
        return 'FlightGear';
      case Simulator.IL2_1946:
        return (long) ? 'IL2-1946' : 'IL2';
      case Simulator.MSFS2020:
        return (long) ? 'Microsoft Flight Simulator 2020' : 'MSFS2020';
      case Simulator.XPlane:
        return 'X-Plane';
      case Simulator.ThisDevice:
        return 'This Device';
      default:
        return 'None';
    }
  }

  static Future<void> loadJsonCheckList(
    String name,
    String path,
    String contents,
  ) async {
    List<CheckListEntry> checklist = [];
    try {
      List<dynamic> itemListJson = jsonDecode(contents);
      List<Map<String, dynamic>> itemListMap =
          itemListJson.cast<Map<String, dynamic>>();
      for (Map<String, dynamic> entry in itemListMap) {
        if (entry['type'] == 'heading') {
          checklist.add(
            CheckListEntry(
              prompt: entry['heading']!,
              expected: '',
              isHeading: true,
            ),
          );
        } else if (entry['type'] == 'item') {
          checklist.add(
            CheckListEntry(
              prompt: entry['prompt']!,
              expected: entry['expected']!,
              isHeading: false,
            ),
          );
        }
      }
    } catch (e, s) {
      Logger.logError('Failed to load checklist: $e', s);
      checklist.add(
        const CheckListEntry(
          prompt: 'Load checklist file',
          expected: 'Failed, check logs',
          isHeading: false,
        ),
      );
    }
    checkLists[name] = CheckList(
      name: name,
      entries: checklist,
      path: path,
    );
  }

  static Future<void> loadTextCheckList(
    String name,
    String path,
    String contents,
  ) async {
    List<CheckListEntry> checklist = [];
    try {
      List<String> entries = contents.split('\n');
      entries = entries.map((element) => element.trim()).toList();
      entries = entries.where((element) => element.isNotEmpty).toList();
      for (String entry in entries) {
        if (entry[0] == '#') {
          name = entry.substring(2);
        }
        if (entry[0] == '=') {
          checklist.add(
            CheckListEntry(
              // Leave space for a space :-)
              prompt: entry.substring(2),
              expected: '',
              isHeading: true,
            ),
          );
        }
        if (entry[0] == '+') {
          List<String> parts = entry.substring(2).split('::');
          checklist.add(
            CheckListEntry(
              prompt: parts[0].trim(),
              expected: parts[1].trim(),
              isHeading: false,
            ),
          );
        }
      }
    } catch (e, s) {
      Logger.logError('Failed to load checklist: $e', s);
      checklist.add(
        const CheckListEntry(
          prompt: 'Load checklist file',
          expected: 'Failed, check logs',
          isHeading: false,
        ),
      );
    }
    checkLists[name] = CheckList(name: name, entries: checklist, path: path);
  }

  static Future<void> loadCheckList(File checkListFile) async {
    List<CheckListEntry> checklist = [];
    try {
      String contents = await checkListFile.readAsString();
      String name =
          checkListFile.path.split('/').last.replaceAll('.checks', '');
      if (contents.trim().startsWith('[')) {
        await loadJsonCheckList(name, checkListFile.path, contents);
      } else {
        await loadTextCheckList(name, checkListFile.path, contents);
      }
    } catch (e, s) {
      Logger.logError('Failed to load checklist ${checkListFile.path}: $e', s);
      checklist.add(
        const CheckListEntry(
          prompt: 'Load checklist file',
          expected: 'Failed, check logs',
          isHeading: false,
        ),
      );
      String name =
          checkListFile.path.split('/').last.replaceAll('.checks', '');
      checkLists[name] = CheckList(
        name: name,
        entries: checklist,
        path: checkListFile.path,
      );
    }
  }

  static Future<void> loadAvailableChecklists() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory checkListDir = Directory('${appDocDir.path}/checklist');
    await checkListDir.create(recursive: true);
    List<FileSystemEntity> contents = await checkListDir.list().toList();
    for (FileSystemEntity entity in contents) {
      if (entity.path.endsWith('.checks') && (entity is File)) {
        await loadCheckList(entity);
      }
    }
  }

  static void removeChecklist(String name) {
    checkLists.remove(name);
  }

  static Future<List<String>> loadableAircraftParams() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory aircraftDir = Directory('${appDocDir.path}/aircraft');
    await aircraftDir.create(recursive: true);
    List<FileSystemEntity> contents = await aircraftDir.list().toList();
    List<String> options = [];
    for (FileSystemEntity entity in contents) {
      if (entity is File) {
        if (entity.path.endsWith('.limits')) {
          options.add(entity.path);
        }
      }
    }
    options.sort();
    return options;
  }
}
