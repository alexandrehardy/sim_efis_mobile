import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/radio_group.dart';

class DropDownRadioWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<String> settings;
  final String selected;
  final ValueChanged<String> onChanged;

  const DropDownRadioWidget({
    Key? key,
    required this.title,
    this.description = '',
    required this.settings,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DropDownRadioWidget> createState() => _DropDownRadioWidgetState();
}

class _DropDownRadioWidgetState extends State<DropDownRadioWidget> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    Widget options;
    options = RadioGroup(
      settings: widget.settings,
      selected: selected ?? widget.selected,
      onChanged: (value) {
        setState(() {
          selected = value;
        });
        widget.onChanged(value);
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: EfisStyle.fieldSize,
              child: Text(
                '${widget.title}:',
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            Expanded(
              child: Text(
                selected ?? widget.selected,
                style: EfisStyle.settingsTextStyle,
                maxLines: 3,
              ),
            ),
          ],
        ),
        if (widget.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 8.0),
            child: Text(
              widget.description,
              style: EfisStyle.settingsTextStyle,
            ),
          ),
        options,
      ],
    );
  }
}
