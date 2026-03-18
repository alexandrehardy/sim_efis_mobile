import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/instruments/primary/primary_flight_display_painter.dart';
import 'package:sim_efis/widgets/bug_setting_button.dart';

class PrimaryFlightDisplay extends StatelessWidget {
  final bool showHeadingTape;
  final bool showDI;
  final bool clip;

  const PrimaryFlightDisplay({
    Key? key,
    this.showHeadingTape = true,
    this.showDI = false,
    this.clip = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget display = StreamBuilder(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (BuildContext context, AsyncSnapshot<UiState> uiState) =>
          StreamBuilder(
        initialData: InstrumentDataStream.instance.current,
        stream: InstrumentDataStream.instance.stream,
        builder:
            (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) =>
                CustomPaint(
          foregroundPainter: PrimaryFlightDisplayPainter(
            state: snapshot.requireData,
            showHeadingTape: showHeadingTape,
            showDI: showDI,
            clip: clip,
            headingBug: uiState.requireData.headingBug,
            altitudeBug: uiState.requireData.altitudeBug,
          ),
          isComplex: false,
          willChange: true,
          child: Container(),
        ),
      ),
    );

    Widget headingBug = StreamBuilder(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (context, AsyncSnapshot<UiState> uiState) {
        return BugSetterWidget(
          angle: uiState.requireData.headingBug * pi / 45.0,
          onTap: () {
            if (uiState.requireData.fixBug) {
              UiStateController.setHeadingBug(
                InstrumentDataStream.instance.current.heading.toInt(),
              );
            } else {
              UiStateController.setHeadingBug(
                uiState.requireData.headingBug +
                    ((uiState.requireData.increaseBug) ? 1 : -1),
              );
            }
          },
          onHold: () {
            if (uiState.requireData.fixBug) {
              UiStateController.setHeadingBug(
                InstrumentDataStream.instance.current.heading.toInt(),
              );
            } else {
              UiStateController.setHeadingBug(
                uiState.requireData.headingBug +
                    ((uiState.requireData.increaseBug) ? 5 : -5),
              );
            }
          },
          label: 'HDG',
        );
      },
    );

    Widget altitudeBug = StreamBuilder(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (context, AsyncSnapshot<UiState> uiState) {
        return BugSetterWidget(
          angle: uiState.requireData.altitudeBug * pi / 1000.0,
          onTap: () {
            int delta = 100;
            if (uiState.requireData.fixBug) {
              UiStateController.setAltitudeBug(
                InstrumentDataStream.instance.current.altitude.toInt(),
              );
            } else {
              if (uiState.requireData.increaseBug) {
                delta = 100 - uiState.requireData.altitudeBug % 100;
              } else {
                delta = uiState.requireData.altitudeBug % 100;
                if (delta == 0) {
                  delta = 100;
                }
              }
              UiStateController.setAltitudeBug(
                uiState.requireData.altitudeBug +
                    ((uiState.requireData.increaseBug) ? delta : -delta),
              );
            }
          },
          onHold: () {
            int delta = 100;
            if (uiState.requireData.fixBug) {
              UiStateController.setAltitudeBug(
                InstrumentDataStream.instance.current.altitude.toInt(),
              );
            } else {
              if (uiState.requireData.increaseBug) {
                delta = 100 - uiState.requireData.altitudeBug % 100;
              } else {
                delta = uiState.requireData.altitudeBug % 100;
                if (delta == 0) {
                  delta = 100;
                }
              }
              UiStateController.setAltitudeBug(
                uiState.requireData.altitudeBug +
                    ((uiState.requireData.increaseBug) ? delta : -delta),
              );
            }
          },
          label: 'ALT',
        );
      },
    );

    Widget increaseBug = StreamBuilder(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (context, AsyncSnapshot<UiState> uiState) {
        return BugSetterWidget(
          onTap: () {
            if (uiState.requireData.fixBug) {
              UiStateController.setIncreaseBug(
                true,
                fix: false,
              );
            } else if (uiState.requireData.increaseBug) {
              UiStateController.setIncreaseBug(
                false,
                fix: false,
              );
            } else {
              UiStateController.setIncreaseBug(
                true,
                fix: true,
              );
            }
          },
          onHold: () {},
          label: (uiState.requireData.fixBug)
              ? 'FIX'
              : ((uiState.requireData.increaseBug) ? '+' : '-'),
          color: (uiState.requireData.fixBug)
              ? EfisColors.background
              : ((uiState.requireData.increaseBug)
                  ? const Color.fromRGBO(0, 128, 0, 1.0)
                  : const Color.fromRGBO(192, 0, 0, 1.0)),
        );
      },
    );

    return Stack(
      children: [
        display,
        Positioned.fill(
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: headingBug,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: altitudeBug,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: increaseBug,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
