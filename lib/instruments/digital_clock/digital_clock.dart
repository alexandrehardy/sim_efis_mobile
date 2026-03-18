import 'package:flutter/material.dart';
import 'package:sim_efis/data/data_stream.dart';
import 'package:sim_efis/data/instrument_data.dart';
import 'package:sim_efis/widgets/connection_status_widget.dart';

class DigitalClock extends StatelessWidget {
  const DigitalClock({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: InstrumentDataStream.instance.current,
        stream: InstrumentDataStream.instance.stream,
        builder:
            (BuildContext context, AsyncSnapshot<InstrumentState> snapshot) {
          int time = snapshot.requireData.time;
          int hour = (time ~/ 60 ~/ 60) % 24;
          int min = (time ~/ 60) % 60;
          int sec = time % 60;
          return Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey, width: 2.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(hour < 10) ? '0' : ''}$hour:${(min < 10) ? '0' : ''}$min:${(sec < 10) ? '0' : ''}$sec',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const ConnectionStatusWidget(),
              ],
            ),
          );
        });
  }
}
