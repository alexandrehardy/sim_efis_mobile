import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

class EfisTab extends StatelessWidget {
  final TextAlign align;
  final String text;
  final bool selected;
  const EfisTab({
    Key? key,
    required this.text,
    required this.align,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 160,
      height: 30,
      decoration: BoxDecoration(
        color: selected ? Colors.green[900] : Colors.transparent,
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          text,
          style: EfisStyle.efisPageButtonStyle,
          textAlign: align,
        ),
      ),
    );
  }
}
