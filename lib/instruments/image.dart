import 'dart:ui';

void drawImage(
  Canvas canvas,
  Image? image,
  Offset offset,
  Paint paint, {
  double scale = 1.0,
}) {
  if (image != null) {
    double width = image.width.toDouble();
    double height = image.height.toDouble();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, width, height),
      Rect.fromLTWH(
        offset.dx - 1.0 * scale,
        offset.dy - 1.0 * scale,
        2.0 * scale,
        2.0 * scale,
      ),
      paint,
    );
  }
}
