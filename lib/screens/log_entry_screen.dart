import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/logbook/logbook.dart';
import 'package:sim_efis/data/logbook/logbook_entry.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/widgets/efis_button.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class LogEntryScreen extends StatefulWidget {
  final LogbookEntry entry;
  final int index;
  const LogEntryScreen({
    Key? key,
    required this.entry,
    required this.index,
  }) : super(key: key);

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  TextEditingController aircraftController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  LogbookEntry entry = LogbookEntry(
    id: 0,
    date: DateTime.now(),
    simulatorTime: 0,
    duration: 0,
    simulator: Simulator.None,
    aircraft: '',
    landings: 0,
    comments: '',
    closed: true,
  );
  int index = 0;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
    index = widget.index;
  }

  @override
  void dispose() {
    aircraftController.dispose();
    commentController.dispose();
    super.dispose();
  }

  TableRow makeRow({required String label, required String value}) {
    return TableRow(
      decoration: const BoxDecoration(
          border: Border(
        top: BorderSide(color: Colors.white),
        left: BorderSide(color: Colors.white),
        right: BorderSide(color: Colors.white),
      )),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('LOGBOOK ENTRY'),
          ],
        ),
        backgroundColor: EfisColors.background,
        actions: [
          if (entry.closed)
            FloatingButton(
              onPressed: () {
                Logbook.instance.deleteEntry(entry);
                Navigator.of(context).pop();
              },
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: null,
      body: Container(
        color: Colors.black45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  if (index > 0)
                    EfisButton(
                      align: TextAlign.center,
                      text: 'PREV',
                      onPressed: () {
                        setState(() {
                          entry = Logbook.instance.entries[index - 1];
                          index = index - 1;
                          aircraftController.text =
                              entry.aircraft.toUpperCase();
                          commentController.text = entry.comments;
                        });
                      },
                    ),
                  Expanded(child: Container()),
                  if (index < Logbook.instance.entries.length - 1)
                    EfisButton(
                      align: TextAlign.center,
                      text: 'NEXT',
                      onPressed: () {
                        setState(() {
                          entry = Logbook.instance.entries[index + 1];
                          index = index + 1;
                          aircraftController.text =
                              entry.aircraft.toUpperCase();
                          commentController.text = entry.comments;
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                scrollDirection: Axis.vertical,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 32.0, right: 32.0, bottom: 32.0),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(150.0),
                        1: FlexColumnWidth(1.0),
                      },
                      children: [
                        makeRow(label: 'ID:', value: '${entry.id}'),
                        makeRow(label: 'DATE:', value: entry.dateString),
                        makeRow(label: 'DURATION:', value: '${entry.duration}'),
                        makeRow(
                            label: 'SIMULATOR:',
                            value: Settings.simulatorString(entry.simulator)),
                        TableRow(
                          decoration: const BoxDecoration(
                              border: Border(
                            top: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                            right: BorderSide(color: Colors.white),
                          )),
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('AIRCRAFT:'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: EfisTextField(
                                controller: aircraftController,
                                compact: true,
                                initialText: entry.aircraft.toUpperCase(),
                                onChanged: (String value) {
                                  entry.aircraft = value;
                                },
                              ),
                            )
                          ],
                        ),
                        makeRow(label: 'LANDINGS:', value: '${entry.landings}'),
                        TableRow(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white)),
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('COMMENTS:'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: EfisTextField(
                                controller: commentController,
                                initialText: entry.comments,
                                maxLines: 10,
                                onChanged: (String value) {
                                  entry.comments = value;
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
