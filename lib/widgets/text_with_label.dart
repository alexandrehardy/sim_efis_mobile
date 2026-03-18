import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';

class TextWithLabel extends StatefulWidget {
  final String label;
  final bool Function(String value) onChanged;
  final String text;
  final TextInputType? keyboardType;

  const TextWithLabel({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.text,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<TextWithLabel> createState() => _TextWithLabelState();
}

class _TextWithLabelState extends State<TextWithLabel> {
  String? text;
  bool error = false;
  TextEditingController controller = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    text = widget.text;
    controller.text = text!;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    text ??= widget.text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: EfisStyle.paramFieldSize,
          child: Text(
            widget.label,
            style: EfisStyle.settingsTextStyle,
          ),
        ),
        Expanded(
          child: EfisTextField(
            keyboardType: widget.keyboardType,
            controller: controller,
            error: error,
            compact: true,
            maxLines: 1,
            onChanged: (String value) {
              bool success = widget.onChanged(value);
              if (!success != error) {
                setState(() {
                  error = !success;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
