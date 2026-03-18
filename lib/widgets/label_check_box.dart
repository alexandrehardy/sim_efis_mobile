import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class LabelCheckbox extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LabelCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LabelCheckbox> createState() => _LabelCheckboxState();
}

class _LabelCheckboxState extends State<LabelCheckbox> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          checkColor: Colors.black,
          fillColor: WidgetStateProperty.all(Colors.white),
          value: value,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                this.value = value;
              });
              widget.onChanged(value);
            }
          },
        ),
        Text(
          widget.label,
          style: EfisStyle.settingsTextStyle.copyWith(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
