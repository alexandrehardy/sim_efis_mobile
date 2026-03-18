import 'package:flutter/material.dart';

class EfisDialogPage extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  const EfisDialogPage({
    Key? key,
    required this.child,
    required this.scrollable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (scrollable)
              ? SingleChildScrollView(
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
