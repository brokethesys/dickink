import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/level_node.dart';
import 'quiz_screen.dart';

class MapScreen extends StatefulWidget {
  final Set<int> completedLevels;
  final ValueChanged<Set<int>>? onLevelsUpdated;

  const MapScreen({
    super.key,
    required this.completedLevels,
    this.onLevelsUpdated,
  });

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
  int coins = 100;
  int currentLevel = 1;

  late AnimationController _xpController;
  late Animation<double> _xpAnimation;

  int get xpForNextLevel => 100;

  int _getCoinsRewardForLevel(int level) {
    if (level <= 5) return 100;
    int rewardStage = ((level - 1) ~/ 5);
    return 100 * rewardStage;
  }

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
      coins = prefs.getInt('coins') ?? 100;
      currentLevel = prefs.getInt('currentLevel') ?? 1;
      final completed = (prefs.getStringList('completedLevels') ?? [])
          .map((e) => int.parse(e))
          .toSet();
      widget.completedLevels.addAll(completed);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', currentLevel);
    await prefs.setStringList(
      'completedLevels',
      widget.completedLevels.map((e) => e.toString()).toList(),
    );
    await prefs.setInt('playerLevel', playerLevel);
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setInt('currentXP', currentXP);
    await prefs.setInt('coins', coins);
  }

  // === Настройки ===
  void _openSettingsPanel(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool localSound = soundEnabled;
    bool localMusic = musicEnabled;
    bool localVibration = vibrationEnabled;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Настройки',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> toggleSetting(String key, bool value) async {
              await prefs.setBool(key, value);
              setState(() {
                if (key == 'soundEnabled') soundEnabled = value;
                if (key == 'musicEnabled') musicEnabled = value;
                if (key == 'vibrationEnabled') vibrationEnabled = value;
              });
            }

            return Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 80, right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(color: Colors.blueGrey.shade900.withOpacity(0.95),
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
                            toggleSetting('soundEnabled', v);
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildRoyaleSwitch(
                          icon: Icons.music_note,
                          label: 'Музыка',
                          value: localMusic,
                          onChanged: (v) {
                            setLocalState(() => localMusic = v);
                            toggleSetting('musicEnabled', v);
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildRoyaleSwitch(
                          icon: Icons.vibration,
                          label: 'Вибрация при ответах',
                          value: localVibration,
                          onChanged: (v) {
                            setLocalState(() => localVibration = v);
                            toggleSetting('vibrationEnabled', v);
                          },
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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF63B4FF), Color(0xFF3389E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF999999), Color(0xFF777777)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color: value ? Colors.greenAccent.shade400 : Colors.grey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
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
      final levelNumber = i + 1;

      final isCompleted = widget.completedLevels.contains(levelNumber);
      final isCurrent = levelNumber == currentLevel;
      final isLocked = levelNumber > currentLevel;

      return Positioned(
        top: c.dy,
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
              setState(() {
                widget.completedLevels.add(levelNumber);
                currentXP += 50;

                while (currentXP >= xpForNextLevel) {
                  currentXP -= xpForNextLevel;
                  playerLevel++;
                  coins += _getCoinsRewardForLevel(playerLevel);
                }

                if (levelNumber == currentLevel) {
                  currentLevel++;
                }

                _saveSettings();
              });

              widget.onLevelsUpdated?.call(widget.completedLevels);
            }
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
            reverse: true,physics: const ClampingScrollPhysics(),
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
            imageAsset: 'assets/images/coin.png',
            label: coins.toString(),
            color: Colors.amber.shade700,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _squareButton(
            icon: Icons.settings,
            color: const Color(0xFF1E88E5),
            onTap: () => _openSettingsPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _squareButton({
    IconData? icon,
    String? imageAsset,
    String? label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color ?? Colors.blueGrey.shade700,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              Image.asset(imageAsset, width: 24, height: 24)
            else if (icon != null)
              Icon(icon, color: Colors.white, size: 24),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// === Рисуем линии пути между уровнями ===
class MapPathPainter extends CustomPainter {
  final List<Offset> centers;

  MapPathPainter(this.centers);

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final pathPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(centers[0].dx, centers[0].dy);
    for (int i = 1; i < centers.length; i++) {
      final mid = Offset(
        (centers[i - 1].dx + centers[i].dx) / 2,
        (centers[i - 1].dy + centers[i].dy) / 2,
      );
      path.quadraticBezierTo(mid.dx, mid.dy, centers[i].dx, centers[i].dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}