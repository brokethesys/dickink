import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/level_node.dart';
import 'quiz_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      body: Stack(
        children: [
          // 🌊 Прокручиваемая карта (фон + путь + уровни)
          SingleChildScrollView(
            reverse: true,
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                // 🖼 Фон, который НЕ растягивается и повторяется по вертикали
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg_map2.png',
                    fit: BoxFit.fitWidth, // ❗️ не растягиваем
                    repeat: ImageRepeat.repeatY, // 🔁 повторяем вверх
                    alignment: Alignment.bottomCenter, // ⚖️ выравниваем по центру
                    filterQuality: FilterQuality.high,
                  ),
                ),

                // 🎢 Волнистая линия + уровни
                SizedBox(
                  height: 2200,
                  child: CustomPaint(
                    painter: MapPathPainter(),
                    child: Stack(
                      children: _buildLevelNodes(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ❤️ Панель жизней (не двигается)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (_) => const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ПОЛОН ЖИЗНИ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Уровни на волне
  List<Widget> _buildLevelNodes(BuildContext context) {
    const int totalLevels = 26;
    const double amplitude = 120;
    const double period = 250;
    const double startY = 2000;
    const double stepY = 150;

    return List.generate(totalLevels, (i) {
      final double y = startY - i * stepY;
      final double x = _waveX(y, amplitude, period);
      return Positioned(
        top: y,
        left: x - 30,
        child: LevelNode(
          levelNumber: i + 1,
          stars: (i + 1) % 4,
          isCurrent: i + 1 == 22,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(level: i + 1),
              ),
            );
          },
        ),
      );
    });
  }

  double _waveX(double y, double amplitude, double period) {
    const double centerX = 200;
    return centerX + sin(y / period) * amplitude;
  }
}

class MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const double amplitude = 120;
    const double period = 250;
    const double centerX = 200;

    final path = Path();
    path.moveTo(centerX + sin(size.height / period) * amplitude, size.height);

    for (double y = size.height; y >= 0; y -= 2) {
      final x = centerX + sin(y / period) * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}