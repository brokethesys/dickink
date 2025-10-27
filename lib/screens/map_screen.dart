import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../widgets/level_node.dart';
import 'quiz_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _xpController;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _xpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // === Построение уровней ===
  List<Offset> _calculateLevelCenters(Size screenSize) {
    const int totalLevels = 25;
    const double amplitude = 120;
    const double period = 250;
    const double centerX = 200;

    final rand = Random(42);

    // Высота карты = 200 пикселей на уровень + отступы сверху/снизу
    final double topPadding = 200;
    final double bottomPadding = 120;
    final double stepY = 200.0;
    final double mapHeight =
        bottomPadding + stepY * (totalLevels - 1) + topPadding;

    return List.generate(totalLevels, (i) {
      final double y = mapHeight - bottomPadding - i * stepY;
      final double x =
          centerX + sin(y / period) * amplitude + rand.nextDouble() * 12 - 6;
      return Offset(x, y);
    });
  }

  List<Widget> _buildLevelNodes(
    BuildContext context,
    GameState state,
    List<Offset> centers,
  ) {
    return List.generate(centers.length, (i) {
      final c = centers[i];
      final levelNumber = i + 1;

      final isCompleted = state.completedLevels.contains(levelNumber);
      final isCurrent = levelNumber == state.currentLevel;
      final isLocked = levelNumber > state.currentLevel;

      return Positioned(
        top: c.dy - 30,
        left: c.dx - 30,
        child: LevelNode(
          levelNumber: levelNumber,
          isCurrent: isCurrent,
          isLocked: isLocked,
          isCompleted: isCompleted,
          onTap: () async {
            if (isLocked) return;
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizScreen(level: levelNumber)),
            );

            if (result == true) {
              state.completeLevel(levelNumber);
              state.addXP(50);
            }
          },
        ),
      );
    });
  }

  // === Настройки ===
  void _openSettingsPanel(BuildContext context) {
    final state = context.read<GameState>();
    bool localSound = state.soundEnabled;
    bool localMusic = state.musicEnabled;
    bool localVibration = state.vibrationEnabled;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Настройки',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 80, right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Настройки',
                          style: TextStyle(
                            fontFamily: 'ClashRoyale',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRoyaleSwitch(
                          icon: Icons.volume_up,
                          label: 'Звук',
                          value: localSound,
                          onChanged: (v) {
                            setLocalState(() => localSound = v);
                            state.toggleSetting('sound', v);
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildRoyaleSwitch(
                          icon: Icons.music_note,
                          label: 'Музыка',
                          value: localMusic,
                          onChanged: (v) {
                            setLocalState(() => localMusic = v);
                            state.toggleSetting('music', v);
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildRoyaleSwitch(
                          icon: Icons.vibration,
                          label: 'Вибрация при ответах',
                          value: localVibration,
                          onChanged: (v) {
                            setLocalState(() => localVibration = v);
                            state.toggleSetting('vibration', v);
                          },
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            await state.resetProgress();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Прогресс успешно сброшен 🧹'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.redAccent, Colors.red],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Сбросить прогресс',
                                  style: TextStyle(
                                    fontFamily: 'ClashRoyale',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Напиши нам на support@quizgame.app 💌',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.orangeAccent,
                                  Colors.deepOrange,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mail_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Обратиться в поддержку',
                                  style: TextStyle(
                                    fontFamily: 'ClashRoyale',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

  Widget _buildRoyaleSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: value
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    Colors.lightBlue.shade300, // верхняя, светлая
                    Colors.lightBlue.shade500, // средняя
                    Colors.blue.shade800, // нижняя, темная (толстая часть)
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.2],
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                    Colors.grey.shade700,
                  ],
                ),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 3,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-1, -1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  // Черная обводка
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'ClashRoyale',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.5
                        ..color = Colors.black,
                    ),
                  ),
                  // Основной белый текст
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'ClashRoyale',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: value
                      ? [
                          Colors.greenAccent.shade200,
                          Colors.green.shade400,
                          Colors.green.shade700,
                        ]
                      : [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                          Colors.grey.shade700,
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    offset: const Offset(-1, -1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                curve: Curves.easeInOut,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === HUD ===
  Widget _topHUD(BuildContext context, GameState state) {
    const double barHeight = 46;
    final xpRatio = state.currentXP / state.xpForNextLevel;

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
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 2,
                ),
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
  child: Stack(
    children: [
      Text(
        '${state.currentXP} / ${state.xpForNextLevel}',
        style: TextStyle(
          fontFamily: 'ClashRoyale',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.black,
        ),
      ),
      Text(
        '${state.currentXP} / ${state.xpForNextLevel}',
        style: const TextStyle(
          fontFamily: 'ClashRoyale',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ],
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
                          '${state.playerLevel}',
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
            imageAsset: 'assets/images/coin.png',
            label: state.coins.toString(),
            color: Colors.amber.shade700,
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
    IconData? icon,
    Color? color,
    String? label,
    String? imageAsset,
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
            if (icon != null)
              Icon(icon, color: color ?? Colors.grey.shade800, size: 28),
            if (imageAsset != null)
              SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final screenSize = MediaQuery.of(context).size;
    final levelCenters = _calculateLevelCenters(screenSize);
    final levelNodes = _buildLevelNodes(context, state, levelCenters);
    final mapHeight = (120 + 200 * 24 + 200)
        .toDouble(); // bottomPadding + stepY*(totalLevels-1) + topPadding

    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
          _topHUD(context, state),
        ],
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

    final path = Path()..moveTo(centers.first.dx, centers.first.dy);
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
