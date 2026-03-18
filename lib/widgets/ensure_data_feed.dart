import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';

class EnsureDataFeed extends StatelessWidget {
  final Widget child;
  const EnsureDataFeed({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InstrumentDataStream.instance.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) => child,
    );
  }
}
