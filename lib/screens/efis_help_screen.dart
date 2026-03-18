import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/screens/help_screen.dart';

class EfisHelpScreen extends HelpScreen {
  const EfisHelpScreen({
    Key? key,
  }) : super(
          key: key,
          title: 'SIM-EFIS HELP',
          background: EfisColors.backgroundDark,
        );

  @override
  Future<String> getHelpMarkDown(BuildContext context) =>
      DefaultAssetBundle.of(context).loadString('assets/help/sim-efis.md');
  @override
  String get resourcePath => 'assets/help';
}
