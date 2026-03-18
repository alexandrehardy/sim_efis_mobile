import 'package:flutter/material.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/widgets/efis_page_button.dart';

class SelectorScreen extends StatelessWidget {
  final SelectedPage page;

  const SelectorScreen({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EfisPageButton(
                text: 'PFD',
                function: EfisPage.primaryFlightDisplay,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'MAP',
                function: EfisPage.map,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'NONE',
                function: EfisPage.none,
                align: TextAlign.center,
                page: page,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EfisPageButton(
                text: 'AIRPORTS',
                function: EfisPage.airports,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'AIRSPACE',
                function: EfisPage.airspace,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'ENGINE',
                function: EfisPage.engine,
                align: TextAlign.center,
                page: page,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EfisPageButton(
                text: 'LOGBOOK',
                function: EfisPage.flightLog,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'PARAMS',
                function: EfisPage.params,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: 'CHKLIST',
                function: EfisPage.checklist,
                align: TextAlign.center,
                page: page,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EfisPageButton(
                text: '6 PACK',
                function: EfisPage.sixPack,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: '9 PACK',
                function: EfisPage.ninePack,
                align: TextAlign.center,
                page: page,
              ),
              EfisPageButton(
                text: '12 PACK',
                function: EfisPage.twelvePack,
                align: TextAlign.center,
                page: page,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
