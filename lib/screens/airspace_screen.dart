import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/airspace/airspace.dart';
import 'package:sim_efis/screens/airspace_list_screen.dart';
import 'package:sim_efis/widgets/efis_button.dart';

enum AirspaceView {
  noView,
  profileView,
  listView,
}

class AirspaceScreen extends StatefulWidget {
  const AirspaceScreen({Key? key}) : super(key: key);

  @override
  State<AirspaceScreen> createState() => _AirspaceScreenState();
}

class _AirspaceScreenState extends State<AirspaceScreen> {
  AirspaceView view = AirspaceView.noView;

  Widget profileAirspaceView(BuildContext context) {
    return StreamBuilder<UiState>(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (BuildContext context, snapshot) {
        return AirspaceWidget(
          showAirspaceLabels: snapshot.requireData.showAirspaceLabels,
          airspaceZoom: snapshot.requireData.airspaceZoom,
        );
      },
    );
  }

  Widget listAirspaceView(BuildContext context) {
    return const AirspaceListScreen();
  }

  Widget selectAirspaceView(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EfisButton(
            text: 'SECTION',
            align: TextAlign.center,
            onPressed: () {
              setState(() {
                view = AirspaceView.profileView;
              });
            },
          ),
          EfisButton(
            text: 'LIST',
            align: TextAlign.center,
            onPressed: () {
              setState(() {
                view = AirspaceView.listView;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case AirspaceView.noView:
        return selectAirspaceView(context);
      case AirspaceView.profileView:
        return profileAirspaceView(context);
      case AirspaceView.listView:
        return listAirspaceView(context);
    }
  }
}
