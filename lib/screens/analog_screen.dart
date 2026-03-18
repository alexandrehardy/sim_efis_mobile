import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/sixpack.dart';

class SixPackScreen extends StatefulWidget {
  const SixPackScreen({Key? key}) : super(key: key);

  @override
  State<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends State<SixPackScreen> {
  Widget getInstrumentView(BuildContext context) {
    return const SixPackInstruments();
  }

  @override
  Widget build(BuildContext context) {
    return getInstrumentView(
      context,
    );
  }
}
