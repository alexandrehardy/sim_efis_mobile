import 'dart:math';

import 'package:flutter/material.dart';

class MapGestureDetector extends StatefulWidget {
  final Widget child;
  final double heading;
  final double mapOffsetX;
  final double mapOffsetY;
  final int zoom;
  final VoidCallback onPanStart;
  final ValueChanged<Offset> onPan;
  final ValueChanged<Offset> onPanEnd;

  const MapGestureDetector({
    Key? key,
    required this.child,
    required this.heading,
    required this.zoom,
    required this.mapOffsetX,
    required this.mapOffsetY,
    required this.onPan,
    required this.onPanEnd,
    required this.onPanStart,
  }) : super(key: key);

  @override
  State<MapGestureDetector> createState() => _MapGestureDetectorState();
}

class _MapGestureDetectorState extends State<MapGestureDetector> {
  Offset start = const Offset(0.0, 0.0);
  Offset end = const Offset(0.0, 0.0);

  Offset remapHeading(Offset delta) {
    double heading = widget.heading * pi / 180.0;
    delta = Offset(delta.dx, -delta.dy);
    Offset up = Offset(sin(heading), -cos(heading));
    Offset right = Offset(cos(heading), sin(heading));
    Offset map = Offset(
      delta.dx * right.dx + delta.dy * right.dy,
      delta.dx * up.dx + delta.dy * up.dy,
    );
    return Offset(map.dx, map.dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        start = details.localPosition;
        end = details.localPosition;
        widget.onPanStart();
      },
      onPanUpdate: (DragUpdateDetails details) {
        end = details.localPosition;
        Offset delta = end - start;
        widget.onPan(remapHeading(delta));
      },
      onPanEnd: (DragEndDetails details) {
        Offset delta = end - start;
        widget.onPanEnd(remapHeading(delta));
      },
      child: widget.child,
    );
  }
}
