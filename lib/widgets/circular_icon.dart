import 'package:flutter/material.dart';

class CircularIconWidget extends StatelessWidget {
  final IconData icon;
  final double size;
  final double padding;
  final double iconSize;

  const CircularIconWidget({
    Key? key,
    required this.icon,
    this.size = 50,
    this.iconSize = 50,
    this.padding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.xor,
            ),
            child: Container(
              width: iconSize,
              height: iconSize,
              color: Colors.black45,
              child: Icon(
                icon,
                size: iconSize - padding * 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
