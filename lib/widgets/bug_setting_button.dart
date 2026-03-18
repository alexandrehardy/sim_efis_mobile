import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/text_style.dart';

class BugSetterWidget extends StatefulWidget {
  final void Function() onTap;
  final void Function() onHold;
  final String label;
  final double angle;
  final Color color;

  const BugSetterWidget({
    Key? key,
    required this.onTap,
    required this.onHold,
    required this.label,
    this.angle = 0.0,
    this.color = EfisColors.background,
  }) : super(key: key);

  @override
  State<BugSetterWidget> createState() => _BugSetterWidgetState();
}

class _BugSetterWidgetState extends State<BugSetterWidget> {
  static const int timerPeriod = 100;
  bool error = false;
  bool onTimer = false;
  int delay = 0;
  Timer? timer;
  double speed = 1.0;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(milliseconds: timerPeriod), (Timer t) {
      if (delay > 0) {
        delay -= timerPeriod;
      }
      if ((delay <= 0) && (onTimer)) {
        widget.onHold();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTimer = false;
        widget.onTap();
      },
      onLongPressDown: (_) {
        onTimer = true;
        delay = 500;
      },
      onLongPressEnd: (_) {
        onTimer = false;
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Transform.rotate(
              angle: widget.angle,
              child: Text(
                widget.label,
                style: EfisStyle.settingsTextStyle.copyWith(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
