import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class EfisTextField extends StatefulWidget {
  final int? maxLines;
  final String? initialText;
  final bool error;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool compact;
  final double? fontSize;

  const EfisTextField({
    Key? key,
    this.maxLines,
    this.onChanged,
    this.initialText,
    this.error = false,
    this.keyboardType,
    this.controller,
    this.compact = false,
    this.fontSize,
  }) : super(key: key);

  @override
  State<EfisTextField> createState() => _EfisTextFieldState();
}

class _EfisTextFieldState extends State<EfisTextField> {
  TextEditingController? controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      controller = TextEditingController(text: widget.initialText);
    } else if (widget.initialText != null) {
      widget.controller!.text = widget.initialText ?? '';
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller ?? controller,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      style: (widget.error)
          ? EfisStyle.settingsErrorTextStyle.copyWith(fontSize: widget.fontSize)
          : EfisStyle.settingsTextStyle.copyWith(fontSize: widget.fontSize),
      decoration: (widget.compact)
          ? const InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              isDense: true,
            )
          : const InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
    );
  }
}
