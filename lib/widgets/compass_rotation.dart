import 'dart:math';

import 'package:flutter/material.dart';

abstract class CompassState {
  void setHeading(double heading);
}

class CompassController {
  CompassState? state;

  void setHeading(double heading) {
    if (state != null) {
      state!.setHeading(heading);
    }
  }
}

class CompassRotation extends StatefulWidget {
  final double initialHeading;
  final CompassController controller;
  final Widget child;

  const CompassRotation({
    Key? key,
    required this.initialHeading,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  State<CompassRotation> createState() => _CompassRotationState();
}

class _CompassRotationState extends State<CompassRotation>
    implements CompassState {
  double heading = 0.0;

  @override
  void initState() {
    super.initState();
    heading = widget.initialHeading;
    widget.controller.state = this;
  }

  @override
  void setHeading(double newHeading) {
    while ((newHeading - heading).abs() > (360 + newHeading - heading).abs()) {
      newHeading = newHeading + 360.0;
    }
    while (
        (newHeading - heading).abs() > (newHeading - 360.0 - heading).abs()) {
      newHeading = newHeading - 360.0;
    }
    if (mounted) {
      setState(() {
        heading = newHeading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: widget.initialHeading, end: heading),
      duration: const Duration(milliseconds: 500),
      builder: (BuildContext context, double heading, Widget? child) {
        return Transform.rotate(
          angle: heading * pi / 180.0,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
