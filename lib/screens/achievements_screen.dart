import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    // === Достижения с динамическим прогрессом ===
    final achievements = [
      {
        "title": "Пройти 3 уровня",
        "progress": gameState.completedLevels.length,
        "goal": 3,
        "reward": 50,
      },
      {
        "title": "Пройти 5 уровней",
        "progress": gameState.completedLevels.length,
        "goal": 5,
        "reward": 75,
      },
      {
        "title": "Открыть 5 фонов",
        "progress": gameState.ownedBackgrounds.length,
        "goal": 5,
        "reward": 100,
      },
      {
        "title": "Заработать 500 монет",
        "progress": gameState.coins,
        "goal": 500,
        "reward": 120,
      },
      {
        "title": "Пройти все 10 уровней",
        "progress": gameState.completedLevels.length,
        "goal": 10,
        "reward": 200,
      },
    ];

    void collectReward(int index, int reward) {
      if (!gameState.isAchievementCollected(index)) {
        gameState.collectAchievement(index, reward);

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
    }

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
                style: TextStyle(
                  color: Colors.white,
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
                    final progress = ach["progress"] as int;
                    final goal = ach["goal"] as int;
                    final reward = ach["reward"] as int;
                    final percent = (progress / goal).clamp(0.0, 1.0);
                    final completed = percent >= 1.0;
                    final collected = gameState.isAchievementCollected(index);

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
                            ach["title"] as String,
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
                                      ? () => collectReward(index, reward)
                                      : null,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            width: constraints.maxWidth * percent,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
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
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    )
                                                  : Text(
                                                      "$progress/$goal",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
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
                                    "+$reward",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..forward();
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