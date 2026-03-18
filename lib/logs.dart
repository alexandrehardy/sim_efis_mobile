import 'dart:async';

class Log {
  final DateTime time;
  final String message;
  final bool showTime;
  const Log({
    required this.time,
    required this.message,
    required this.showTime,
  });
}

class Logger {
  static const maxStackTraceEntries = 10;
  static const int maxLogs = 100;
  static List<Log> logs = [];
  static bool streaming = false;
  static StreamController<bool> logStreamController =
      StreamController.broadcast(
    onListen: () {
      streaming = true;
    },
    onCancel: () {
      streaming = false;
    },
  );

  static void _addLog(Log log) {
    logs.add(log);
    if (logs.length > maxLogs) {
      logs.removeAt(0);
    }
    if (streaming) {
      logStreamController.add(true);
    }
  }

  static void log(String message) {
    _addLog(
      Log(
        showTime: true,
        time: DateTime.now(),
        message: message,
      ),
    );
  }

  static void logError(String error, StackTrace s) {
    DateTime timeStamp = DateTime.now();
    _addLog(
      Log(
        showTime: true,
        time: timeStamp,
        message: error,
      ),
    );
    List<String> stackLines = s.toString().split('\n');
    for (String frame in stackLines.take(maxStackTraceEntries)) {
      _addLog(
        Log(
          showTime: true,
          time: timeStamp,
          message: frame,
        ),
      );
    }
  }

  static void clear() {
    logs.clear();
    if (streaming) {
      logStreamController.add(true);
    }
  }

  static Stream<bool> get logStream => logStreamController.stream;
}
