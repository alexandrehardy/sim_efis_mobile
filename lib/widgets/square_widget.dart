import 'package:flutter/material.dart';

class SquareWidget extends StatelessWidget {
  final Widget child;
  const SquareWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight > constraints.maxWidth) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            child: child,
          );
        } else {
          return SizedBox(
            width: constraints.maxHeight,
            height: constraints.maxHeight,
            child: child,
          );
        }
      },
    );
  }
}
