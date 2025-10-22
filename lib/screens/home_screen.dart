import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;
  double _indicatorPosition = 1.0;

  int coins = 120; // текущие монеты
  Set<int> completedLevels = {}; // хранение завершённых уровней

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _indicatorPosition =
            ((_pageController.page ?? _currentPage).clamp(0.0, 2.0)).toDouble();
      });
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 120;
      completedLevels = (prefs.getStringList('completedLevels') ?? [])
          .map((e) => int.parse(e))
          .toSet();
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onBottomNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.shop,
      Icons.map_rounded,
      Icons.workspace_premium,
    ];
    const labels = [
      'Магазин',
      'Уровни',
      'Достижения',
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 67, 91, 112),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          const ShopScreen(),
          MapScreen(
            completedLevels: completedLevels,
            onLevelsUpdated: (levels) {
              setState(() {
                completedLevels = levels;
              });
            },
          ),
          AchievementsScreen(
            coins: coins,
            completedLevels: completedLevels.length, // <- передаем количество пройденных уровней
            onCoinsUpdated: (newCoins) async {
              setState(() {
                coins = newCoins;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('coins', coins);
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(icons, labels),
    );
  }

  Widget _buildBottomBar(List<IconData> icons, List<String> labels) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 74, 87, 110),
            Color.fromARGB(255, 59, 70, 88)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(
          top: BorderSide(color: Colors.black54, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment((_indicatorPosition - 1) / 1, 0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 74, 110, 143),
                      Color.fromARGB(255, 83, 124, 160),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),),
              ),
            ),
          ),
          Row(
            children: List.generate(3, (i) {
              final bool active = _currentPage == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onBottomNavTap(i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: i != 2
                          ? const Border(
                              right: BorderSide(
                                color: Color.fromARGB(255, 91, 102, 123),
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[i],
                            size: active ? 34 : 30,
                            color: active ? Colors.white : Colors.white70,
                            shadows: active
                                ? [
                                    const Shadow(
                                      color: Colors.black,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: TextStyle(
                              color: active ? Colors.white : Colors.white70,
                              fontWeight:
                                  active ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                              shadows: active
                                  ? [
                                      const Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}