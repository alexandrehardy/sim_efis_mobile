import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/screens/help_screen.dart';
import 'package:sim_efis/settings.dart';

class ConfigHelpScreen extends HelpScreen {
  final Simulator simulator;

  const ConfigHelpScreen({
    Key? key,
    required this.simulator,
  }) : super(
          key: key,
          title: 'SIM CONFIGURATION',
          background: EfisColors.backgroundDark,
        );

  @override
  Future<String> getHelpMarkDown(BuildContext context) =>
      Settings.configHelpForSimulator(context, simulator);
  @override
  String get resourcePath => 'assets/sim_config';
}
