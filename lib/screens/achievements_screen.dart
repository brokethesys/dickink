import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🏆 Достижения (в разработке)',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
