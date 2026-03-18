import 'package:sim_efis/settings.dart';

class LogbookEntry {
  final int id;
  final DateTime date;
  final int simulatorTime;
  double duration; // in hours
  final Simulator simulator;
  String aircraft;
  int landings;
  String comments;
  bool closed;

  LogbookEntry({
    required this.id,
    required this.date,
    required this.simulatorTime,
    required this.duration,
    required this.simulator,
    required this.aircraft,
    required this.landings,
    required this.comments,
    required this.closed,
  });

  LogbookEntry copyWith({
    int? id,
    DateTime? date,
    int? simulatorTime,
    double? duration,
    Simulator? simulator,
    String? aircraft,
    int? landings,
    String? comments,
    bool? closed,
  }) {
    return LogbookEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      simulatorTime: simulatorTime ?? this.simulatorTime,
      duration: duration ?? this.duration,
      simulator: simulator ?? this.simulator,
      aircraft: aircraft ?? this.aircraft,
      landings: landings ?? this.landings,
      comments: comments ?? this.comments,
      closed: closed ?? this.closed,
    );
  }

  String get dateString =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['id'] = id;
    data['date'] = date.toIso8601String();
    data['simulatorTime'] = simulatorTime;
    data['duration'] = duration;
    data['simulator'] = Settings.simulatorString(simulator, long: false);
    data['aircraft'] = aircraft;
    data['landings'] = landings;
    data['comments'] = comments;
    data['closed'] = closed;
    return data;
  }

  static final Map<String, Simulator> _stringToSimulator = {};

  static void _setupSimulatorLookup() {
    if (_stringToSimulator.isEmpty) {
      for (Simulator sim in Simulator.values) {
        _stringToSimulator[Settings.simulatorString(sim, long: false)] = sim;
      }
    }
  }

  static Simulator _getSimulatorFromString(String name) {
    _setupSimulatorLookup();
    Simulator sim = _stringToSimulator[name] ?? Simulator.None;
    return sim;
  }

  static LogbookEntry fromJson(Map<String, dynamic> data) {
    _setupSimulatorLookup();
    Simulator simulator = _getSimulatorFromString(data['simulator']);
    return LogbookEntry(
      id: data['id'],
      date: DateTime.parse(data['date']),
      simulatorTime: data['simulatorTime'],
      duration: data['duration'],
      simulator: simulator,
      aircraft: data['aircraft'],
      landings: data['landings'],
      comments: data['comments'],
      closed: data['closed'],
    );
  }
}
