import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          ShopScreen(),
          MapScreen(),
          AchievementsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    const icons = [
      Icons.storefront_rounded,
      Icons.map_rounded,
      Icons.emoji_events_rounded,
    ];
    const labels = [
      'Магазин',
      'Уровни',
      'Достижения',
    ];

    return Container(
      height: 78,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003A6E), Color(0xFF001C3A)],
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
      child: Row(
        children: List.generate(3, (i) {
          final bool active = _currentPage == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onBottomNavTap(i),
              child: Container(
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFFC107),
                            Color(0xFFFF9800),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  border: i != 2
                      ? const Border(
                          right: BorderSide(color: Colors.black26, width: 1),
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
    );
  }
}
