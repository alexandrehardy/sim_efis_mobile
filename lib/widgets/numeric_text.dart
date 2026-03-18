import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class NumericTextWidget extends StatefulWidget {
  final String label;
  final bool Function(double value) onChanged;
  final double value;
  final double min;
  final double max;

  const NumericTextWidget({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  State<NumericTextWidget> createState() => _NumericTextWidgetState();
}

class _NumericTextWidgetState extends State<NumericTextWidget> {
  static const int timerPeriod = 100;
  double value = 0.0;
  bool error = false;
  bool onTimer = false;
  double increment = 0.0;
  int delay = 0;
  Timer? timer;
  double speed = 1.0;

  @override
  void initState() {
    super.initState();
    value = widget.value;
    timer =
        Timer.periodic(const Duration(milliseconds: timerPeriod), (Timer t) {
      if (delay > 0) {
        delay -= timerPeriod;
      }
      if ((delay <= 0) && (onTimer)) {
        updateValue(increment);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumericTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void updateValue(double amount) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if ((value + amount >= widget.min) && (value + amount <= widget.max)) {
        setState(() {
          value = value + amount;
          widget.onChanged(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.max - widget.min <= 1000.0) {
      speed = 1.0;
    } else {
      speed = 10.0;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: EfisStyle.paramFieldSize,
          child: Text(widget.label, style: EfisStyle.settingsTextStyle),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: Text('$value', style: EfisStyle.settingsTextStyle),
                ),
              ),
              const SizedBox(width: 8.0),
              GestureDetector(
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 42,
                ),
                onLongPressDown: (_) {
                  increment = speed;
                  onTimer = true;
                  delay = 1000;
                },
                onLongPressEnd: (_) {
                  onTimer = false;
                },
                onTap: () {
                  onTimer = false;
                  updateValue(speed);
                },
              ),
              GestureDetector(
                child: const Icon(
                  Icons.remove_circle,
                  color: Colors.white,
                  size: 42,
                ),
                onLongPressDown: (_) {
                  increment = -speed;
                  onTimer = true;
                  delay = 1000;
                },
                onLongPressEnd: (_) {
                  onTimer = false;
                },
                onTap: () {
                  onTimer = false;
                  updateValue(-speed);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
