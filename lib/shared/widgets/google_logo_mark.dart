import 'package:flutter/material.dart';

class GoogleLogoMark extends StatelessWidget {
  const GoogleLogoMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.shortestSide * 0.22;
    final Rect outer = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.10,
      size.width * 0.80,
      size.height * 0.80,
    );

    final Paint blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final Paint red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final Paint yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final Paint green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Draw the familiar multicolor ring with a small gap on the right side.
    canvas.drawArc(outer, 3.90, 0.95, false, blue);
    canvas.drawArc(outer, 4.85, 1.05, false, red);
    canvas.drawArc(outer, 5.90, 0.85, false, yellow);
    canvas.drawArc(outer, 0.10, 1.55, false, green);

    // Inner cutout keeps the mark crisp at button sizes.
    final Paint inner = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.50),
      size.shortestSide * 0.22,
      inner,
    );

    // Horizontal blue bar that makes the mark read as the Google "G".
    final Paint bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.46,
          size.height * 0.42,
          size.width * 0.26,
          size.height * 0.16,
        ),
        Radius.circular(size.shortestSide * 0.07),
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}