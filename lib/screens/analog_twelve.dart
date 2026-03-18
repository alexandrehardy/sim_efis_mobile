import 'package:flutter/material.dart';
import 'package:sim_efis/instruments/twelve_pack.dart';

class TwelvePackScreen extends StatefulWidget {
  const TwelvePackScreen({Key? key}) : super(key: key);

  @override
  State<TwelvePackScreen> createState() => _TwelvePackScreenState();
}

class _TwelvePackScreenState extends State<TwelvePackScreen> {
  Widget getInstrumentView(BuildContext context) {
    return const TwelvePackInstruments();
  }

  @override
  Widget build(BuildContext context) {
    return getInstrumentView(
      context,
    );
  }
}
