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

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  int playerLevel = 1;
  int currentXP = 50;
  int coins = 120;

  late AnimationController _xpController;
  late Animation<double> _xpAnimation;

  int get xpForNextLevel => (100 * pow(1.5, playerLevel - 1)).round();

  @override
  void initState() {
    super.initState();
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _xpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _xpController, curve: Curves.easeOutCubic),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _xpController.dispose();
    super.dispose();
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
                            activeThumbColor: Colors.orangeAccent,
                            value: soundEnabled,
                            onChanged: (v) {
                              setState(() => soundEnabled = v);
                              setStateDialog(() => soundEnabled = v);
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Музыка'),
                            activeThumbColor: Colors.orangeAccent,
                            value: musicEnabled,
                            onChanged: (v) {
                              setState(() => musicEnabled = v);
                              setStateDialog(() => musicEnabled = v);
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Вибрация при правильных ответах'),
                            activeThumbColor: Colors.orangeAccent,
                            value: vibrationEnabled,
                            onChanged: (v) {
                              setState(() => vibrationEnabled = v);
                              setStateDialog(() => vibrationEnabled = v);
                              _saveSettings();
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.mail_outline,
                                color: Colors.orangeAccent),
                            title: const Text('Обратиться в поддержку'),
                            subtitle: const Text('support@quizgame.app'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Напиши нам на support@quizgame.app 💌'),
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

  // 📍 центры уровней — синусоида + лёгкий шум
  List<Offset> _calculateLevelCenters() {
    const int totalLevels = 26;
    const double amplitude = 120;
    const double period = 250;
    const double startY = 2000;
    const double stepY = 150;
    const double centerX = 200;

    final rand = Random(42);

    return List.generate(totalLevels, (i) {
      final double y = startY - i * stepY;
      final double x =
          centerX + sin(y / period) * amplitude + rand.nextDouble() * 12 - 6;
      return Offset(x, y);
    });
  }

  List<Widget> _buildLevelNodes(BuildContext context) {
    final centers = _calculateLevelCenters();
    return List.generate(centers.length, (i) {
      final c = centers[i];
      return Positioned(
        top: c.dy,
        left: c.dx - 30,
        child: LevelNode(
          levelNumber: i + 1,
          stars: (i + 1) % 4,
          isCurrent: i + 1 == 22,
          onTap: () {
            setState(() {
              currentXP += 40;
              if (currentXP >= xpForNextLevel) {
                currentXP -= xpForNextLevel;
                playerLevel++;
              }
              _saveSettings();
              _xpController.forward(from: 0);
            });

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizScreen(level: i + 1)),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mapHeight = 2200;
    final double xpProgress = currentXP / xpForNextLevel;
    _xpController.value = xpProgress.clamp(0.0, 1.0);

    final levelCenters = _calculateLevelCenters();
    final levelNodes = _buildLevelNodes(context);

    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      body: Stack(
        children: [
          SingleChildScrollView(
            reverse: true,
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/new_bg_map.jpg',
                    fit: BoxFit.fitWidth,
                    repeat: ImageRepeat.repeatY,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(
                  height: mapHeight,
                  child: CustomPaint(
                    painter: MapPathPainter(levelCenters),
                    child: Stack(children: levelNodes),
                  ),
                ),
              ],
            ),
          ),
          _topHUD(),
        ],
      ),
    );
  }

  Widget _topHUD() {
    const double barHeight = 46;
    final xpRatio = currentXP / xpForNextLevel;

    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 33, 38),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.black.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final progressWidth =
                          constraints.maxWidth * xpRatio.clamp(0.0, 1.0);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: progressWidth,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 81, 103),
                              Color.fromARGB(255, 0, 141, 184),
                              Color.fromARGB(255, 2, 194, 227),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      '$currentXP / $xpForNextLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 52,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 7, 102, 131),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$playerLevel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          _squareButton(
            icon: Icons.monetization_on,
            color: Colors.amber.shade700,
            label: coins.toString(),
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _squareButton(
            icon: Icons.settings,
            color: const Color(0xFF333333),
            onTap: () => _openSettingsPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _squareButton({
    required IconData icon,
    Color? color,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color ?? Colors.grey.shade800, size: 28),
            if (label != null)
              Positioned(
                bottom: 3,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MapPathPainter extends CustomPainter {
  final List<Offset> centers;

  MapPathPainter(this.centers);

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.isEmpty) return;

    final path = Path();
    path.moveTo(centers.first.dx, centers.first.dy);

    for (int i = 1; i < centers.length; i++) {
      final p1 = centers[i - 1];
      final p2 = centers[i];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
    }

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final paint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) =>
      oldDelegate.centers != centers;
}
