import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// 💡 Глобальное значение текущего выбранного фона.
/// Используется и в магазине, и на экране уровней.
final ValueNotifier<String> currentBackground = ValueNotifier<String>('blue');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF001B33),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}