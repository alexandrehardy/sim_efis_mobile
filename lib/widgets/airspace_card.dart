import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/airspace_colors.dart';
import 'package:sim_efis/data/ui_state.dart';

class AirspaceCard extends StatelessWidget {
  final Airspace airspace;
  final double distance;
  const AirspaceCard({
    Key? key,
    required this.airspace,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = getAirspaceColor(airspace);
    double displayDist = (distance * 10).roundToDouble() / 10.0;
    String frequencies = airspace.frequencies
        .map((e) => '${e.type.toString()}:${e.value} MHz')
        .join(', ');
    String displayText = frequencies.isNotEmpty
        ? '$displayDist nm, $frequencies'
        : '$displayDist nm';
    return Card(
      child: ListTile(
        title: Text(
          airspace.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${airspace.lowerLimit.toString()} to ${airspace.upperLimit.toString()}'),
            Text(displayText),
          ],
        ),
        trailing: GestureDetector(
          child: const Icon(Icons.location_pin, size: 32),
          onTap: () {
            UiStateController.zoomMapToPosition(
              airspace.centre.latitude,
              airspace.centre.longitude,
            );
          },
        ),
      ),
    );
  }
}
