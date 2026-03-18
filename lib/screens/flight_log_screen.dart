import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/data/logbook/logbook.dart';
import 'package:sim_efis/data/logbook/logbook_entry.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/screens/log_entry_screen.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class FlightLogScreen extends StatefulWidget {
  const FlightLogScreen({Key? key}) : super(key: key);

  @override
  State<FlightLogScreen> createState() => _FlightLogScreenState();
}

class FLightLogDataSource extends DataTableSource {
  Logbook logbook = Logbook.instance;
  BuildContext context;
  VoidCallback onEditComplete;
  FLightLogDataSource(this.context, {required this.onEditComplete});

  @override
  DataRow getRow(int index) {
    LogbookEntry entry = logbook.entries[index];
    List<String> commentLines = entry.comments.split('\n');
    String comment = commentLines.first;
    if (commentLines.length > 1) {
      comment = '$comment ...';
    }
    return DataRow(
      color: WidgetStateProperty.all(
        entry.closed ? Colors.transparent : Colors.green[900],
      ),
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(Icons.edit, color: Colors.white),
              const SizedBox(width: 8),
              Text('${entry.id}'),
            ],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogEntryScreen(
                  entry: entry,
                  index: index,
                ),
                fullscreenDialog: true,
              ),
            );
            Logbook.instance.saveLogbook();
            onEditComplete();
          },
        ),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(Text(entry.dateString)),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(Text('${entry.duration}')),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(Text(Settings.simulatorString(entry.simulator, long: false))),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(Text(entry.aircraft.toUpperCase())),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(Text('${entry.landings}')),
        const DataCell(VerticalDivider(color: Colors.white)),
        DataCell(
          SizedBox(
            width: 150.0,
            child: Text(
              comment,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogEntryScreen(
                  entry: entry,
                  index: index,
                ),
                fullscreenDialog: true,
              ),
            );
            onEditComplete();
          },
        ),
      ],
    );
  }

  @override
  int get rowCount => logbook.entries.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _FlightLogScreenState extends State<FlightLogScreen> {
  double headingRowHeight = 56.0;
  double paginateHeight = 56.0;
  double rowHeight = 30.0;
  double calcRowHeight = 31.0;

  @override
  Widget build(BuildContext context) {
    bool canOpenFlight = Logbook.instance.canOpenFlight;
    bool canCloseFlight = Logbook.instance.canCloseFlight;
    Widget button = Container();
    if ((canOpenFlight) || (canCloseFlight)) {
      button = FloatingButton(
        label: Text(
          canOpenFlight ? 'OPEN' : 'CLOSE',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        onPressed: () {
          setState(() {
            if (canOpenFlight) {
              Logbook.instance.openFlight();
            } else {
              Logbook.instance.closeFlight();
            }
          });
        },
      );
    }

    ThemeData themeData = Theme.of(context);
    //TODO: On turning, the number of rows are not changed.
    return Stack(
      children: [
        const SizedBox.expand(),
        Positioned.fill(
          child: StreamBuilder<UiState>(
            initialData: UiStateController.state,
            stream: UiStateController.stream,
            builder: (BuildContext context, snapshot) => LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  Theme(
                data: themeData.copyWith(
                  dividerColor: Colors.white,
                  textTheme: Typography.material2021().white,
                  cardTheme: themeData.cardTheme.copyWith(
                    color: Colors.black54,
                  ),
                ),
                child: PaginatedDataTable(
                  arrowHeadColor: Colors.white,
                  columnSpacing: 10.0,
                  headingRowHeight: headingRowHeight,
                  rowsPerPage: max(
                      ((constraints.maxHeight -
                              headingRowHeight -
                              paginateHeight) ~/
                          calcRowHeight),
                      1),
                  dataRowMinHeight: rowHeight,
                  dataRowMaxHeight: rowHeight,
                  columns: [
                    DataColumn(
                      label: const Text('ID'),
                      onSort: (int column, bool descending) {},
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    DataColumn(
                      label: const Text('DATE'),
                      onSort: (int column, bool descending) {},
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    DataColumn(
                      label: const Text('DURATION'),
                      onSort: (int column, bool descending) {},
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    DataColumn(
                      label: const Text('SIMULATOR'),
                      onSort: (int column, bool descending) {},
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    DataColumn(
                      label: const Text('AIRCRAFT'),
                      onSort: (int column, bool descending) {},
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    const DataColumn(
                      label: Text('LANDINGS'),
                    ),
                    const DataColumn(
                        label: VerticalDivider(color: Colors.white)),
                    const DataColumn(
                      label: Text('COMMENTS'),
                    ),
                  ],
                  source: FLightLogDataSource(
                    context,
                    onEditComplete: () {
                      setState(() {
                        // Erm. Nothing to do here
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: button,
          ),
        ),
      ],
    );
  }
}
