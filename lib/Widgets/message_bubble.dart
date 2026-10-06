import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  final Color color;
  BubblePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Desenha o corpo do balão (Retângulo arredondado)
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width - 10, size.height),
      const Radius.circular(16),
    ));

    // Desenha a pontinha (triângulo) apontando para a direita
    path.moveTo(size.width - 10, size.height / 2 - 8);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 10, size.height / 2 + 8);
    path.close();

    // Sombra leve para dar profundidade
    canvas.drawShadow(path, Colors.black, 4.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}