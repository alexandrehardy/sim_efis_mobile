import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/airspeed/airspeed.dart';
import 'package:sim_efis/instruments/altimeter/altimeter.dart';
import 'package:sim_efis/instruments/attitude/attitude.dart';
import 'package:sim_efis/instruments/direction/direction.dart';
import 'package:sim_efis/instruments/flaps/flaps.dart';
import 'package:sim_efis/instruments/gear/gear.dart';
import 'package:sim_efis/instruments/rpm/rpm.dart';
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
  gear,
  flaps,
  rpm,
}

class NinePackLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    double horizontalGap = 0.5;
    double verticalGap = 0.5;
    double width = (size.width - horizontalGap * 4.0) / 3.0;
    double height = (size.height - verticalGap * 4.0) / 3.0;
    double caseSide = min(width, height);
    Size caseSize = Size(caseSide, caseSide);
    double left = (size.width - (caseSide * 3.0 + horizontalGap * 2.0)) / 2.0;
    double top = (size.height - (caseSide * 3.0 + verticalGap * 2.0)) / 2.0;
    double firstRow = top;
    double secondRow = verticalGap + caseSide + top;
    double thirdRow = verticalGap * 2.0 + caseSide * 2.0 + top;
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
    if (hasChild('LGR')) {
      layoutChild('LGR', BoxConstraints.tight(caseSize));
      positionChild('LGR', Offset(firstCol, thirdRow));
    }
    if (hasChild('FLP')) {
      layoutChild('FLP', BoxConstraints.tight(caseSize));
      positionChild('FLP', Offset(secondCol, thirdRow));
    }
    if (hasChild('RPM')) {
      layoutChild('RPM', BoxConstraints.tight(caseSize));
      positionChild('RPM', Offset(thirdCol, thirdRow));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

class NinePackInstruments extends StatefulWidget {
  const NinePackInstruments({Key? key}) : super(key: key);

  @override
  State<NinePackInstruments> createState() => _NinePackInstrumentsState();
}

class _NinePackInstrumentsState extends State<NinePackInstruments> {
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
      'LGR': selectInstrument(
        instrument: const GearIndicator(),
        value: InstrumentSelected.gear,
      ),
      'FLP': selectInstrument(
        instrument: const FlapsIndicator(),
        value: InstrumentSelected.flaps,
      ),
      'RPM': selectInstrument(
        instrument: const RpmIndicator(engine: 0),
        value: InstrumentSelected.rpm,
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
      case InstrumentSelected.gear:
        return instruments['LGR']!;
      case InstrumentSelected.flaps:
        return instruments['FLP']!;
      case InstrumentSelected.rpm:
        return instruments['RPM']!;
      case InstrumentSelected.all:
        return CustomMultiChildLayout(
          delegate: NinePackLayoutDelegate(),
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
