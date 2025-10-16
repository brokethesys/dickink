import 'package:flutter/material.dart';

class LevelNode extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final bool isCurrent;
  final VoidCallback? onTap;

  const LevelNode({
    super.key,
    required this.levelNumber,
    required this.stars,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCurrent)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.lightBlueAccent, width: 8),
              ),
            ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.deepOrangeAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$levelNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                stars,
                (index) => const Icon(Icons.star, color: Colors.amber, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
