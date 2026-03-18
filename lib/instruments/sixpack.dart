import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/airspeed/airspeed.dart';
import 'package:sim_efis/instruments/altimeter/altimeter.dart';
import 'package:sim_efis/instruments/attitude/attitude.dart';
import 'package:sim_efis/instruments/direction/direction.dart';
import 'package:sim_efis/instruments/slipturn/slipturn.dart';
import 'package:sim_efis/instruments/variometer/variometer.dart';

enum InstrumentSelected {
  all,
  airspeed,
  attitude,
  altitude,
  slipturn,
  direction,
  variometer,
}

class SixPackLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    double horizontalGap = 0.5;
    double verticalGap = 0.5;
    double width = (size.width - horizontalGap * 4.0) / 3.0;
    double height = (size.height - verticalGap * 3.0) / 2.0;
    double caseSide = min(width, height);
    Size caseSize = Size(caseSide, caseSide);
    double left = (size.width - (caseSide * 3.0 + horizontalGap * 2.0)) / 2.0;
    double top = (size.height - (caseSide * 2.0 + verticalGap)) / 2.0;
    double firstRow = top;
    double secondRow = verticalGap + caseSide + top;
    double firstCol = left;
    double secondCol = horizontalGap + caseSide + left;
    double thirdCol = horizontalGap * 2.0 + caseSide * 2.0 + left;

    if (hasChild('ASI')) {
      layoutChild('ASI', BoxConstraints.tight(caseSize));
      positionChild('ASI', Offset(firstCol, firstRow));
    }
    if (hasChild('HSI')) {
      layoutChild('HSI', BoxConstraints.tight(caseSize));
      positionChild('HSI', Offset(secondCol, firstRow));
    }
    if (hasChild('ALT')) {
      layoutChild('ALT', BoxConstraints.tight(caseSize));
      positionChild('ALT', Offset(thirdCol, firstRow));
    }
    if (hasChild('SLP')) {
      layoutChild('SLP', BoxConstraints.tight(caseSize));
      positionChild('SLP', Offset(firstCol, secondRow));
    }
    if (hasChild('DIR')) {
      layoutChild('DIR', BoxConstraints.tight(caseSize));
      positionChild('DIR', Offset(secondCol, secondRow));
    }
    if (hasChild('VSI')) {
      layoutChild('VSI', BoxConstraints.tight(caseSize));
      positionChild('VSI', Offset(thirdCol, secondRow));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

class SixPackInstruments extends StatefulWidget {
  const SixPackInstruments({Key? key}) : super(key: key);

  @override
  State<SixPackInstruments> createState() => _SixPackInstrumentsState();
}

class _SixPackInstrumentsState extends State<SixPackInstruments> {
  InstrumentSelected selected = InstrumentSelected.all;

  Widget selectInstrument({
    required Widget instrument,
    required InstrumentSelected value,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          if (selected == value) {
            selected = InstrumentSelected.all;
          } else {
            selected = value;
          }
        });
      },
      child: instrument,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> instruments = {
      'ASI': selectInstrument(
        instrument: const AirspeedIndicator(),
        value: InstrumentSelected.airspeed,
      ),
      'HSI': selectInstrument(
        instrument: const AttitudeIndicator(),
        value: InstrumentSelected.attitude,
      ),
      'ALT': selectInstrument(
        instrument: const Altimeter(),
        value: InstrumentSelected.altitude,
      ),
      'SLP': selectInstrument(
        instrument: const SlipTurnIndicator(),
        value: InstrumentSelected.slipturn,
      ),
      'DIR': selectInstrument(
        instrument: const DirectionIndicator(),
        value: InstrumentSelected.direction,
      ),
      'VSI': selectInstrument(
        instrument: const Variometer(),
        value: InstrumentSelected.variometer,
      ),
    };

    switch (selected) {
      case InstrumentSelected.airspeed:
        return instruments['ASI']!;
      case InstrumentSelected.attitude:
        return instruments['HSI']!;
      case InstrumentSelected.altitude:
        return instruments['ALT']!;
      case InstrumentSelected.slipturn:
        return instruments['SLP']!;
      case InstrumentSelected.direction:
        return instruments['DIR']!;
      case InstrumentSelected.variometer:
        return instruments['VSI']!;
      case InstrumentSelected.all:
        return CustomMultiChildLayout(
          delegate: SixPackLayoutDelegate(),
          children: instruments.entries
              .map(
                (entry) => LayoutId(
                  id: entry.key,
                  child: entry.value,
                ),
              )
              .toList(),
        );
    }
  }
}
