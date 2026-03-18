import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/airspace/airspace_painter.dart';
import 'package:sim_efis/widgets/circular_icon.dart';

class AirspaceWidget extends StatelessWidget {
  static const int maxZoom = 10;
  static const int minZoom = 1;
  final bool showAirspaceLabels;
  final int airspaceZoom;

  const AirspaceWidget({
    Key? key,
    required this.showAirspaceLabels,
    required this.airspaceZoom,
  }) : super(key: key);

  Widget buildControlStack(int zoom) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.add,
            size: 50,
            iconSize: 42,
            padding: 4,
          ),
          onTap: () {
            if (zoom < maxZoom) {
              UiStateController.setAirspaceZoom(zoom + 1);
            }
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: const CircularIconWidget(
            icon: Icons.remove,
            size: 50,
            iconSize: 42,
            padding: 4,
          ),
          onTap: () {
            if (zoom > minZoom) {
              UiStateController.setAirspaceZoom(zoom - 1);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StreamBuilder<InstrumentState>(
          stream: InstrumentDataStream.instance.stream,
          initialData: InstrumentDataStream.instance.currentUI,
          builder:
              (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) {
            return CustomPaint(
              foregroundPainter: AirspacePainter(
                latitude: snapshot.requireData.latitude,
                longitude: snapshot.requireData.longitude,
                heading: snapshot.requireData.trueHeading,
                altitude: snapshot.requireData.altitude,
                pitch: snapshot.requireData.pitch,
                airspeed: snapshot.requireData.indicatedAirspeed,
                vsi: snapshot.requireData.variometer,
                showAirspaceLabels: showAirspaceLabels,
                scale: airspaceZoom,
              ),
              isComplex: false,
              willChange: true,
              child: Container(),
            );
          },
        ),
        Positioned.fill(
          child: buildControlStack(airspaceZoom),
        ),
      ],
    );
  }
}
