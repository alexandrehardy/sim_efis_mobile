import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';

class ImageViewerScreen extends StatelessWidget {
  final String title;
  final String assetImage;

  const ImageViewerScreen({
    Key? key,
    required this.title,
    required this.assetImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: EfisColors.background,
        actions: const [],
      ),
      body: SizedBox.expand(
        child: Container(
          color: Colors.white30,
          child: InteractiveViewer(
            child: Image.asset(
              assetImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
