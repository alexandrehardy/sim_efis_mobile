import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';

class TextWithDefault extends StatefulWidget {
  final String label;
  final bool Function(String value) onChanged;
  final Future<String> Function() onDefault;
  final String text;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const TextWithDefault({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.onDefault,
    required this.text,
    this.keyboardType,
    this.controller,
  }) : super(key: key);

  @override
  State<TextWithDefault> createState() => _TextWithDefaultState();
}

class _TextWithDefaultState extends State<TextWithDefault> {
  String? text;
  bool error = false;
  bool disposeController = false;
  TextEditingController? controller;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    if (widget.controller != null) {
      controller = widget.controller!;
      disposeController = false;
    } else {
      controller = TextEditingController(text: '');
      disposeController = true;
    }
    controller?.text = text!;
  }

  @override
  void dispose() {
    if (disposeController) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    text ??= widget.text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EfisStyle.fieldSize,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: EfisStyle.settingsTextStyle),
                      Text(
                        '(Click for default)',
                        style: EfisStyle.settingsTextStyle
                            .copyWith(fontSize: 12.0),
                      )
                    ],
                  ),
                  onTap: () async {
                    controller?.text = await widget.onDefault();
                    if (error) {
                      setState(() {
                        error = false;
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: EfisTextField(
            keyboardType: widget.keyboardType,
            controller: controller,
            error: error,
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
