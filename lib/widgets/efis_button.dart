import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class EfisButton extends StatelessWidget {
  final TextAlign align;
  final String text;
  final VoidCallback onPressed;
  final bool selected;
  const EfisButton({
    Key? key,
    required this.text,
    required this.align,
    required this.onPressed,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: (selected)
            ? WidgetStateProperty.all(Colors.green[900])
            : WidgetStateProperty.all(Colors.black45),
        side: WidgetStateProperty.all(
          const BorderSide(
            color: Colors.grey,
          ),
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        onPressed();
      },
      child: SizedBox(
        width: 70,
        child: Text(
          text,
          style: EfisStyle.efisPageButtonStyle,
          textAlign: align,
        ),
      ),
    );
  }
}
