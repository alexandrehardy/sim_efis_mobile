import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/logbook/logbook.dart';
import 'package:sim_efis/data/plugins/base.dart';
import 'package:sim_efis/data/plugins/empty.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/network.dart';
import 'package:sim_efis/settings.dart';

class InstrumentJob {}

class PollInstrumentJob extends InstrumentJob {}

class DrawInstrumentJob extends InstrumentJob {}

class InitPluginJob extends InstrumentJob {
  final InstrumentDataSourcePlugin plugin;
  InitPluginJob(this.plugin);
}

class ClosePluginJob extends InstrumentJob {}

class SetAircraftLimits extends InstrumentJob {
  final AircraftLimits limits;
  SetAircraftLimits(this.limits);
}

class InstrumentDataStream {
  static InstrumentDataStream? _instance;
  bool alive = false;
  int pollInterval = 50; // milliseconds
  int drawInterval = 20; // milliseconds
  InstrumentState currentUI;
  InstrumentState current;
  AircraftLimits limits = const AircraftLimits();
  String currentAircraftName = '';
  InstrumentDataSourcePlugin _plugin;
  late StreamController<InstrumentState> streamController;
  StreamController<InstrumentJob> jobsStreamController = StreamController();
  Timer? simPollTimer;
  Timer? uiDrawTimer;
  DateTime lastDraw = DateTime.now();
  bool airborne = false;

  InstrumentDataStream({
    required InstrumentDataSourcePlugin plugin,
  })  : _plugin = plugin,
        current = InstrumentState(lastResponse: DateTime(0)),
        currentUI = InstrumentState(lastResponse: DateTime(0)) {
    streamController = StreamController.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
    processJobs(jobsStreamController.stream);
  }

  Future<void> processJob(InstrumentJob job) async {
    if (job is InitPluginJob) {
      UiStateController.resetMap();
      InstrumentDataSourcePlugin oldPlugin = _plugin;
      _plugin = job.plugin;
      await oldPlugin.close();
      Logbook.instance.closeFlight();
      Logger.log('Closed ${oldPlugin.name}');
      String connectTo = Settings.connectTo;
      String? listenOn = Settings.listenOn;
      int port =
          Settings.port ?? NetworkPorts.defaultPorts[Settings.simulator] ?? 0;
      await _plugin.init(
        connectTo: connectTo,
        port: port,
        simulator: Settings.simulator,
      );
      Logger.log(
          'Opened ${_plugin.name}: ${listenOn ?? '0.0.0.0'} <-> $connectTo port:$port');
    } else if (job is PollInstrumentJob) {
      await pollPlugin();
    } else if (job is DrawInstrumentJob) {
      await updateInstruments();
    } else if (job is SetAircraftLimits) {
      limits = job.limits;
    }
  }

  Future<void> processJobs(Stream<InstrumentJob> stream) async {
    await for (final InstrumentJob job in stream) {
      try {
        await processJob(job);
      } catch (e, s) {
        Logger.logError('Failed to handle $job}: $e', s);
      }
    }
  }

  Future<void> loadLimitsForAircraft(String aircraft) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory aircraftDir = Directory('${appDocDir.path}/aircraft');
    await aircraftDir.create(recursive: true);
    File limitsFile = File('${aircraftDir.path}/$aircraft.limits');
    if (await limitsFile.exists()) {
      String limitsString = await limitsFile.readAsString();
      limits = AircraftLimits.decode(limitsString);
    } else {
      limits = const AircraftLimits();
    }
  }

  void updateLandings() {
    if (_plugin.hasAltitudeAboveGround) {
      if (airborne) {
        if ((current.indicatedAirspeed < current.limits.vs) &&
            (current.variometer >= -0.01) &&
            (current.altitudeAboveGround < 100.0)) {
          airborne = false;
          Logbook.instance.logLanding();
        }
      } else {
        if ((current.indicatedAirspeed > current.limits.vs) &&
            (current.altitudeAboveGround >= 100.0)) {
          airborne = true;
        }
      }
    } else {
      if (airborne) {
        if ((current.indicatedAirspeed < current.limits.vs * 0.7) &&
            (current.variometer >= -0.01)) {
          airborne = false;
          Logbook.instance.logLanding();
        }
      } else {
        if (current.indicatedAirspeed > current.limits.vs) {
          airborne = true;
        }
      }
    }
  }

  Future<void> pollPlugin() async {
    if (!alive) return;
    try {
      current = await _plugin.poll(current);
      if (current.aircraftType != currentAircraftName) {
        currentAircraftName = current.aircraftType;
        await loadLimitsForAircraft(current.aircraftType.toUpperCase());
        UiStateController.resetMap();
      }

      bool isActive = active;
      if (isActive) {
        updateLandings();
      }
      UiStateController.setConnectedState(isActive);
    } catch (e, s) {
      Logger.logError('${_plugin.name}: Failed processing messages $e', s);
    }
  }

  Future<void> updateInstruments() async {
    if (!alive) return;
    DateTime now = DateTime.now();
    double rate =
        now.difference(lastDraw).inMicroseconds / 1000.0 / (drawInterval);
    if (rate < 1e-5) {
      rate = 1e-5;
    }
    if (rate > 10.0) {
      rate = 10.0;
    }
    lastDraw = now;
    currentUI =
        currentUI.interpolate(current, 0.1 * rate).copyWith(limits: limits);
    streamController.sink.add(currentUI);
  }

  void forceStateDelivery() {
    if (!alive) return;
    streamController.sink.add(currentUI);
  }

  void onListen() {
    alive = true;
    simPollTimer = Timer.periodic(
      Duration(milliseconds: pollInterval),
      (timer) {
        jobsStreamController.add(PollInstrumentJob());
      },
    );

    uiDrawTimer = Timer.periodic(
      Duration(milliseconds: drawInterval),
      (timer) {
        jobsStreamController.add(DrawInstrumentJob());
      },
    );
  }

  void onCancel() {
    alive = false;
    simPollTimer!.cancel();
    simPollTimer = null;
    uiDrawTimer!.cancel();
    uiDrawTimer = null;
  }

  Stream<InstrumentState> get stream => streamController.stream;
  static InstrumentDataStream get instance {
    InstrumentDataSourcePlugin plugin = EmptySourcePlugin();
    plugin.init(
      connectTo: Settings.connectTo,
      port: Settings.port ?? NetworkPorts.defaultPorts[Settings.simulator] ?? 0,
      simulator: Settings.simulator,
    );
    _instance ??= InstrumentDataStream(
      plugin: plugin,
    );
    return _instance!;
  }

  InstrumentDataSourcePlugin get plugin => _plugin;
  set plugin(InstrumentDataSourcePlugin value) {
    jobsStreamController.add(InitPluginJob(value));
  }

  static void resetPlugin({bool force = false}) {
    bool reset =
        force || InstrumentDataStream.instance.plugin.reconnectAfterSleep;
    if (reset) {
      InstrumentDataStream.instance.plugin =
          Settings.pluginForDriver(Settings.driver);
    }
  }

  void setAircraftLimits(AircraftLimits limits) {
    jobsStreamController.add(SetAircraftLimits(limits));
  }

  bool get active =>
      _plugin.active &&
      current.lastResponse.isAfter(DateTime.now().subtract(
        const Duration(seconds: 5),
      ));
}
