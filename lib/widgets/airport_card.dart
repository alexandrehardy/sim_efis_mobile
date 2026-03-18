import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/airspace.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/widgets/compass_rotation.dart';

class AirportCard extends StatefulWidget {
  final Airport airport;
  final double distance;
  final double trueHeading;
  final void Function(Airport airport) onInfoPressed;
  const AirportCard({
    Key? key,
    required this.airport,
    required this.distance,
    required this.trueHeading,
    required this.onInfoPressed,
  }) : super(key: key);

  @override
  State<AirportCard> createState() => _AirportCardState();
}

class _AirportCardState extends State<AirportCard> {
  CompassController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompassController();
  }

  @override
  void didUpdateWidget(covariant AirportCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller!.setHeading(widget.trueHeading);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Navigate map smoothly
    double displayDist = (widget.distance * 10).roundToDouble() / 10.0;
    return Card(
      child: ListTile(
        title: Text(
          widget.airport.name +
              ((widget.airport.icaoCode != null)
                  ? ' (${widget.airport.icaoCode})'
                  : ''),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$displayDist nm'),
        trailing: Wrap(
          children: [
            CompassRotation(
              initialHeading: widget.trueHeading,
              controller: _controller!,
              child: const Icon(CupertinoIcons.location_north_fill, size: 32),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              child: const Icon(Icons.location_pin, size: 32),
              onTap: () {
                UiStateController.zoomMapToPosition(
                  widget.airport.location.latitude,
                  widget.airport.location.longitude,
                );
              },
            ),
            const SizedBox(width: 10),
            GestureDetector(
              child: const Icon(Icons.info_outline, size: 32),
              onTap: () {
                widget.onInfoPressed(widget.airport);
              },
            ),
          ],
        ),
      ),
    );
  }
}
