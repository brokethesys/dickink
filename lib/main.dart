import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/game_state.dart';
import 'screens/home_screen.dart';

/// 💡 Глобальное значение текущего выбранного фона.
/// Используется и в магазине, и на экране уровней.
final ValueNotifier<String> currentBackground = ValueNotifier<String>('blue');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем сохранённое состояние игры из SharedPreferences
  final gameState = await GameState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameState>.value(value: gameState),
      ],
      child: const MyApp(),
    ),
  );
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