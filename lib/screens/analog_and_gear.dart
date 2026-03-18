import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/ninepack.dart';

class NinePackScreen extends StatefulWidget {
  const NinePackScreen({Key? key}) : super(key: key);

  @override
  State<NinePackScreen> createState() => _NinePackScreenState();
}

class _NinePackScreenState extends State<NinePackScreen> {
  Widget getInstrumentView(BuildContext context) {
    return const NinePackInstruments();
  }

  @override
  Widget build(BuildContext context) {
    return getInstrumentView(
      context,
    );
  }
}
