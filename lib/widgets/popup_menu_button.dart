import 'package:flutter/material.dart';

class EfisPopupMenuButton extends StatelessWidget {
  const EfisPopupMenuButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 60.0,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          boxShadow: kElevationToShadow[9],
        ),
        child: const Icon(Icons.settings),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 0,
          child: Text(
            'Setting',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
