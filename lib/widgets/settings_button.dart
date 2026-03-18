import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;

  const SettingsButton({
    Key? key,
    this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: TextButton(
        style: ButtonStyle(
          shadowColor: null,
          elevation: WidgetStateProperty.all<double>(
            0.0,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: const BorderSide(
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            Colors.transparent,
          ),
        ),
        onPressed: onPressed,
        child: label,
      ),
    );
  }
}
