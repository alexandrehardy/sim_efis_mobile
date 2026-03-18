import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final String? title;
  final List<String> settings;
  final String selected;
  final ValueChanged<String> onChanged;
  final Widget Function(String option)? builder;

  const RadioGroup({
    Key? key,
    this.title,
    required this.settings,
    required this.selected,
    required this.onChanged,
    this.builder,
  }) : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    String? title = widget.title;
    String groupValue = selected ?? widget.selected;
    List<Widget> options = widget.settings
        .map((value) => Row(
              children: [
                Radio(
                  value: value,
                  groupValue: groupValue,
                  activeColor: Colors.white,
                  fillColor: WidgetStateProperty.all(Colors.white),
                  onChanged: (String? value) {
                    setState(
                      () {
                        if (value != null) {
                          selected = value;
                          widget.onChanged(value);
                        }
                      },
                    );
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    child: (widget.builder != null)
                        ? widget.builder!(value)
                        : Text(value),
                    onTap: () {
                      setState(
                        () {
                          selected = value;
                          widget.onChanged(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        if (title != null) Text(title),
        ...options,
      ],
    );
  }
}
