import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class LabelledValue extends StatelessWidget {
  final String label;
  final String value;

  const LabelledValue({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EfisStyle.fieldSize,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label, style: EfisStyle.settingsTextStyle)],
          ),
        ),
        Expanded(
          child: Text(value, style: EfisStyle.settingsTextStyle),
        ),
      ],
    );
  }
}
