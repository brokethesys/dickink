import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  final int coins;
  final int completedLevels;
  final ValueChanged<int> onCoinsUpdated;

  const AchievementsScreen({
    super.key,
    required this.coins,
    required this.completedLevels,
    required this.onCoinsUpdated,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late int coins;

  List<Map<String, dynamic>> achievements = [
    {
      "title": "Пройти 3 уровня",
      "goal": 3,
      "reward": 50,
      "collected": false,
    },
    {
      "title": "Пройти 5 уровней",
      "goal": 5,
      "reward": 75,
      "collected": false,
    },
    {
      "title": "Открыть 5 фонов",
      "goal": 5,
      "reward": 100,
      "collected": false,
    },
    {
      "title": "Заработать 500 монет",
      "goal": 500,
      "reward": 120,
      "collected": false,
    },
    {
      "title": "Пройти все 10 уровней",
      "goal": 10,
      "reward": 200,
      "collected": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    coins = widget.coins;
    _loadCollectedAchievements();
  }

  @override
  void didUpdateWidget(covariant AchievementsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateProgress();
  }

  void _updateProgress() {
    // Автоматически обновляем прогресс на основе состояния игрока
    for (var ach in achievements) {
      if (ach["title"].contains("Пройти")) {
        ach["progress"] = widget.completedLevels;
      } else if (ach["title"].contains("монет")) {
        ach["progress"] = widget.coins;
      } else {
        ach["progress"] = 0; // Для "Открыть 5 фонов" если не реализовано
      }
    }
    setState(() {});
  }

  Future<void> _loadCollectedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> collected =
        prefs.getStringList('collectedAchievements') ?? [];
    setState(() {
      for (int i = 0; i < achievements.length; i++) {
        achievements[i]["collected"] = collected.contains(i.toString());
      }
    });
    _updateProgress();
  }

  Future<void> _saveCollectedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> collected = [];
    for (int i = 0; i < achievements.length; i++) {
      if (achievements[i]["collected"] == true) {
        collected.add(i.toString());
      }
    }
    await prefs.setStringList('collectedAchievements', collected);
  }

  void _showCoinPopup(int reward) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 150,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: _AnimatedCoinPopup(reward: reward),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  void _collectReward(int index) {
    final ach = achievements[index];
    if (ach["collected"] == true) return;

    setState(() {
      coins += (ach["reward"] as int);
      ach["collected"] = true;
    });

    widget.onCoinsUpdated(coins);
    _showCoinPopup(ach["reward"] as int);
    _saveCollectedAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 50, 70, 90),
            Color.fromARGB(255, 25, 35, 50)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Достижения",
                style: TextStyle(color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = achievements[index];
                    final double progress =
                        (ach["progress"] ?? 0).toDouble();
                    final double percent =
                        (progress / ach["goal"]).clamp(0.0, 1.0);
                    final bool completed = percent >= 1.0;
                    final bool collected = ach["collected"] == true;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 70, 90, 110),
                            Color.fromARGB(255, 50, 65, 85)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ach["title"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: completed && !collected
                                      ? () => _collectReward(index)
                                      : null,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            width: constraints.maxWidth *
                                                percent,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              gradient: LinearGradient(
                                                colors: completed
                                                    ? [
                                                        Colors.amberAccent,
                                                        Colors.orangeAccent,
                                                      ]
                                                    : [
                                                        const Color.fromARGB(
                                                            255, 90, 140, 180),
                                                        const Color.fromARGB(
                                                            255, 70, 120, 160),
                                                      ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: completed && !collected
                                              ? const Text(
                                                  "Получить награду",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                )
                                              : collected
                                                  ? const Text(
                                                      "Награда получена",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    )
                                                  : Text(
                                                      "${ach["progress"] ?? 0}/${ach["goal"]}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Image.asset(
                                      'assets/images/coin.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "+${ach["reward"]}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCoinPopup extends StatefulWidget {
  final int reward;
  const _AnimatedCoinPopup({required this.reward});

  @override
  State<_AnimatedCoinPopup> createState() => _AnimatedCoinPopupState();
}

class _AnimatedCoinPopupState extends State<_AnimatedCoinPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0, 1.5), end: const Offset(0, -1.5))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  late final Animation<double> _opacity =
      Tween(begin: 1.0, end: 0.0).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: Image.asset(
                  'assets/images/coin.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "+${widget.reward}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}