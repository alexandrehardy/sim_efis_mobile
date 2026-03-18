import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/efis.dart';

class EfisScreen extends StatefulWidget {
  const EfisScreen({Key? key}) : super(key: key);

  @override
  State<EfisScreen> createState() => _EfisScreenState();
}

class _EfisScreenState extends State<EfisScreen> {
  Widget getInstrumentView(BuildContext context) {
    return const EfisAttitudeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return getInstrumentView(
      context,
    );
  }
}
