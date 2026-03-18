import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/logbook/logbook_entry.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/settings.dart';

enum LogbookJob { load, save }

class Logbook {
  StreamController<LogbookJob> controller = StreamController();
  static Logbook? _instance;
  LogbookEntry? _openFlight;
  List<LogbookEntry> entries = [];

  Logbook() {
    _processJobs(controller.stream);
  }

  static Logbook get instance {
    _instance ??= Logbook();
    return _instance!;
  }

  Future<void> _processJobs(Stream<LogbookJob> stream) async {
    await for (final LogbookJob job in stream) {
      try {
        switch (job) {
          case LogbookJob.load:
            await _loadLogbook();
            break;
          case LogbookJob.save:
            await _saveLogbook();
            break;
        }
      } catch (e) {
        Logger.log('Failed to process logbook: $e');
      }
    }
  }

  void openFlight() {
    if (_openFlight != null) {
      closeFlight();
    }
    _openFlight = LogbookEntry(
      id: nextId,
      date: DateTime.now(),
      duration: 0.0,
      simulator: Settings.simulator,
      simulatorTime: InstrumentDataStream.instance.current.time,
      aircraft: InstrumentDataStream.instance.currentAircraftName,
      landings: 0,
      comments: '',
      closed: false,
    );
    entries.add(_openFlight!);
    saveLogbook();
    UiStateController.setLogbookStatus(true);
  }

  void closeFlight() {
    if (_openFlight != null) {
      DateTime end = DateTime.now();
      _openFlight!.duration =
          (end.difference(_openFlight!.date).inMinutes / 60.0 * 10.0)
                  .truncateToDouble() /
              10.0;
      _openFlight!.closed = true;
      _openFlight = null;
      saveLogbook();
      UiStateController.setLogbookStatus(false);
    }
  }

  void logLanding() {
    if (_openFlight != null) {
      _openFlight!.landings++;
    }
  }

  int get nextId {
    if (entries.isEmpty) {
      return 1;
    }
    return entries
            .map((e) => e.id)
            .reduce((entry1, entry2) => max(entry1, entry2)) +
        1;
  }

  void deleteEntry(LogbookEntry entry) {
    entries.removeWhere((e) => e.id == entry.id);
    saveLogbook();
  }

  Future<void> _loadLogbook() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory logbookDir = Directory('${appDocDir.path}/logbook');
    await logbookDir.create(recursive: true);
    File logbookFile = File('${logbookDir.path}/logbook.json');
    if (await logbookFile.exists()) {
      String stringLogbook = await logbookFile.readAsString();
      Map<String, dynamic> logbookJson = jsonDecode(stringLogbook);
      List<dynamic> jsonList = logbookJson['entries'];
      List<Map<String, dynamic>> jsonEntries =
          jsonList.cast<Map<String, dynamic>>();
      List<LogbookEntry> newEntries = [];
      LogbookEntry? openFlight;
      for (Map<String, dynamic> entry in jsonEntries) {
        LogbookEntry newEntry = LogbookEntry.fromJson(entry);
        newEntries.add(newEntry);
        if (!newEntry.closed) {
          openFlight = newEntry;
        }
      }
      entries = newEntries;
      _openFlight = openFlight;
    }
  }

  Future<void> _saveLogbook() async {
    List<Map<String, dynamic>> jsonEntries = [];
    for (LogbookEntry entry in entries) {
      jsonEntries.add(entry.toJson());
    }
    String stringLogbook = jsonEncode({'entries': jsonEntries});
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory logbookDir = Directory('${appDocDir.path}/logbook');
    await logbookDir.create(recursive: true);
    File logbookFile = File('${logbookDir.path}/logbook.json');
    await logbookFile.writeAsString(stringLogbook);
  }

  void loadLogbook() {
    controller.add(LogbookJob.load);
  }

  void saveLogbook() {
    controller.add(LogbookJob.save);
  }

  bool get canCloseFlight => _openFlight != null;
  bool get canOpenFlight =>
      (!canCloseFlight) &&
      //(Settings.simulator != Simulator.None) &&
      //(Settings.simulator != Simulator.Random) &&
      (InstrumentDataStream.instance.active);
}

class FilteredLogBook {
  DateTime? day;
  Simulator? simulator;
  String? aircraft;
  Logbook source;
  List<LogbookEntry> entries;

  FilteredLogBook({
    this.day,
    this.simulator,
    this.aircraft,
    required this.source,
    this.entries = const [],
  }) {
    DateTime? date;
    if (day != null) {
      date = DateTime(
        day!.year,
        day!.month,
        day!.day,
      );
    }

    entries = source.entries.where((entry) {
      if (date != null) {
        DateTime entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        if (!date.isAtSameMomentAs(entryDate)) {
          return false;
        }
      }

      if (simulator != null) {
        if (entry.simulator != simulator) {
          return false;
        }
      }

      if (aircraft != null) {
        if (entry.aircraft.toUpperCase() != aircraft!.toUpperCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  static List<LogbookEntry> filterLogbook({required Logbook source}) {
    return [];
  }
}
