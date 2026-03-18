import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;

  const FloatingButton({
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
          elevation: WidgetStateProperty.resolveWith<double>(
            (states) => (states.contains(WidgetState.pressed)) ? 1.0 : 10.0,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(
                color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor ??
                    Colors.blueAccent,
              ),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).floatingActionButtonTheme.foregroundColor ??
                Colors.blueAccent,
          ),
        ),
        onPressed: onPressed,
        child: label,
      ),
    );
  }
}
