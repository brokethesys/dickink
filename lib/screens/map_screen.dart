import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/level_node.dart';
import 'quiz_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  int playerLevel = 1;
  int currentXP = 50;
  int coins = 120;

  // Экспоненциальный рост опыта
  int get xpForNextLevel => (100 * pow(1.5, playerLevel - 1)).round();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      musicEnabled = prefs.getBool('musicEnabled') ?? true;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      playerLevel = prefs.getInt('playerLevel') ?? 1;
      currentXP = prefs.getInt('currentXP') ?? 50;
      coins = prefs.getInt('coins') ?? 120;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setInt('playerLevel', playerLevel);
    await prefs.setInt('currentXP', currentXP);
    await prefs.setInt('coins', coins);
  }

  void _openSettingsPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Настройки',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 80, right: 16),
            child: Material(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 260,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Настройки',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001B33),
                            ),
                          ),
                          const SizedBox(height: 12),

                          SwitchListTile(
                            title: const Text('Звук'),
                            activeColor: Colors.orangeAccent,
                            value: soundEnabled,
                            onChanged: (v) {
                              setState(() => soundEnabled = v);
                              setStateDialog(() => soundEnabled = v);
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Музыка'),
                            activeColor: Colors.orangeAccent,
                            value: musicEnabled,
                            onChanged: (v) {
                              setState(() => musicEnabled = v);
                              setStateDialog(() => musicEnabled = v);
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(title: const Text('Вибрация при правильных ответах'),
                            activeColor: Colors.orangeAccent,
                            value: vibrationEnabled,
                            onChanged: (v) {
                              setState(() => vibrationEnabled = v);
                              setStateDialog(() => vibrationEnabled = v);
                              _saveSettings();
                            },
                          ),

                          const Divider(),

                          ListTile(
                            leading: const Icon(Icons.mail_outline, color: Colors.orangeAccent),
                            title: const Text('Обратиться в поддержку'),
                            subtitle: const Text('support@quizgame.app'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Напиши нам на support@quizgame.app 💌'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, -0.1),
            end: Offset.zero,
          ).animate(anim1),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double mapHeight = 2200;
    final double xpProgress = currentXP / xpForNextLevel;

    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      body: Stack(
        children: [
          // 🖼 Фон
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_map2.png',
              fit: BoxFit.fitWidth,
              repeat: ImageRepeat.repeatY,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
            ),
          ),

          // 🌊 Прокручиваемая карта
          SingleChildScrollView(
            reverse: true,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: mapHeight,
                minHeight: mapHeight,
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: mapHeight,
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
          ),

          // ❤️ Панель жизней
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

          // 🧭 Верхняя панель (XP + монеты + настройки)
          Positioned(top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔹 Прогресс-бар опыта
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ур. $playerLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: xpProgress.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currentXP / $xpForNextLevel XP',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 🪙 Монеты
                _squareButton(
                  icon: Icons.monetization_on,
                  color: Colors.amberAccent,
                  label: coins.toString(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Это ваши монетки 💰'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // ⚙️ Настройки
                _squareButton(
                  icon: Icons.settings,
                  color: Colors.white,
                  onTap: () => _openSettingsPanel(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔲 Виджет квадратного хитбокса
  Widget _squareButton({
    required IconData icon,
    Color? color,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color ?? Colors.white, size: 26),
            if (label != null)
              Positioned(
                bottom: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🎯 Генерация уровней
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
            // Добавим опыт при прохождении уровня
            setState(() {currentXP += 40;
              if (currentXP >= xpForNextLevel) {
                currentXP -= xpForNextLevel;
                playerLevel++;
              }
              _saveSettings();
            });

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