import 'package:flutter/material.dart';

class LevelNode extends StatelessWidget {
  final int levelNumber;
  final bool isCurrent;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LevelNode({
    super.key,
    required this.levelNumber,
    this.isCurrent = false,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isCompleted
        ? const Color(0xFFFFD700) // золотой
        : Colors.white;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 🔵 Сам уровень
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked ? Colors.grey[300] : baseColor,
              border: Border.all(
                color: isLocked
                    ? Colors.grey
                    : (isCompleted
                        ? Colors.amber.shade700
                        : const Color.fromARGB(255, 49, 195, 41)),
                width: 5,
              ),
              boxShadow: [
                if (!isLocked)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$levelNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isLocked ? Colors.grey[700] : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}