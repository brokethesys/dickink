import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🛒 Магазин (в разработке)',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
