import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class LogEntry extends StatelessWidget {
  final Log log;
  const LogEntry({Key? key, required this.log}) : super(key: key);

  String pad(int digit) {
    if (digit < 10) {
      return '0$digit';
    } else {
      return '$digit';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime displayTime = log.time.toLocal();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (log.showTime)
          SizedBox(
            width: 100,
            child: Text(
              '${pad(displayTime.hour)}:${pad(displayTime.minute)}:${pad(displayTime.second)}:',
            ),
          ),
        if (!log.showTime)
          const SizedBox(
            width: 100,
          ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            log.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  Widget logList() {
    DateTime now = DateTime.now();
    DateTime lastDay = DateTime(now.year, now.month, now.day);
    List<Widget> children = [];
    children.add(const Center(child: Text('--- START ---')));
    for (Log log in Logger.logs) {
      DateTime logDay = DateTime(log.time.year, log.time.month, log.time.day);
      if (!logDay.isAtSameMomentAs(lastDay)) {
        children.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(logDay.toString().replaceAll('00:00:00.000', '')),
          ),
        );
        lastDay = logDay;
      }
      children.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: LogEntry(log: log),
        ),
      );
    }

    children.add(const Center(child: Text('--- END ---')));
    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('LOGS'),
          ],
        ),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () {
              Logger.clear();
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'CLEAR',
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
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.black45,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
              child: StreamBuilder<bool>(
                stream: Logger.logStream,
                builder: (context, snapshot) {
                  return logList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
