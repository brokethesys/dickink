import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  bool soundEnabled;
  bool musicEnabled;
  bool vibrationEnabled;

  int playerLevel;
  int currentXP;
  int coins;
  int currentLevel;
  Set<int> completedLevels;

  // Магазин
  List<String> ownedBackgrounds;
  String selectedBackground;

  // Достижения (индексы собранных наград)
  Set<int> collectedAchievements;

  GameState({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.playerLevel = 1,
    this.currentXP = 0,
    this.coins = 0,
    this.currentLevel = 1,
    Set<int>? completedLevels,
    List<String>? ownedBackgrounds,
    this.selectedBackground = 'blue',
    Set<int>? collectedAchievements,
  })  : completedLevels = completedLevels ?? {},
        ownedBackgrounds = ownedBackgrounds ??
            ['blue', 'green', 'purple', 'orange'], // стартовые фоны
        collectedAchievements = collectedAchievements ?? {};

  // === Константы ===
  int get xpForNextLevel => 150;

  int getCoinsRewardForLevel(int level) {
    int rewardStage = ((level - 1) ~/ 5) + 1;
    return rewardStage * 100;
  }

  // === Загрузка и сохранение ===
  static Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();

    return GameState(
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      musicEnabled: prefs.getBool('musicEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      playerLevel: prefs.getInt('playerLevel') ?? 1,
      currentXP: prefs.getInt('currentXP') ?? 0,
      coins: prefs.getInt('coins') ?? 0,
      currentLevel: prefs.getInt('currentLevel') ?? 1,
      completedLevels: (prefs.getStringList('completedLevels') ?? [])
          .map((e) => int.parse(e))
          .toSet(),
      ownedBackgrounds:
          prefs.getStringList('ownedBackgrounds') ?? ['blue', 'green', 'purple', 'orange'],
      selectedBackground: prefs.getString('selectedBackground') ?? 'blue',
      collectedAchievements: (prefs.getStringList('collectedAchievements') ?? [])
          .map((e) => int.parse(e))
          .toSet(),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setInt('playerLevel', playerLevel);
    await prefs.setInt('currentXP', currentXP);
    await prefs.setInt('coins', coins);
    await prefs.setInt('currentLevel', currentLevel);
    await prefs.setStringList(
      'completedLevels',
      completedLevels.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList('ownedBackgrounds', ownedBackgrounds);
    await prefs.setString('selectedBackground', selectedBackground);
    await prefs.setStringList(
      'collectedAchievements',
      collectedAchievements.map((e) => e.toString()).toList(),
    );
  }

  Future<void> resetProgress() async {
    playerLevel = 1;
    currentXP = 0;
    coins = 0;
    currentLevel = 1;
    completedLevels.clear();
    ownedBackgrounds = ['blue', 'green', 'purple', 'orange'];
    selectedBackground = 'blue';
    collectedAchievements.clear();
    notifyListeners();
    await save();
  }

  // === Обновления прогресса ===
  void addXP(int xp) {
    currentXP += xp;
    while (currentXP >= xpForNextLevel) {
      currentXP -= xpForNextLevel;
      playerLevel++;
      coins += getCoinsRewardForLevel(playerLevel);
    }
    notifyListeners();
    save();
  }

  void completeLevel(int levelNumber) {
    completedLevels.add(levelNumber);
    if (levelNumber == currentLevel) currentLevel++;
    notifyListeners();
    save();
  }

  void toggleSetting(String setting, bool value) {
    switch (setting) {
      case 'sound':
        soundEnabled = value;
        break;
      case 'music':
        musicEnabled = value;
        break;
      case 'vibration':
        vibrationEnabled = value;
        break;
    }
    notifyListeners();
    save();
  }

  // === Магазин фонов ===
  void selectBackground(String id) {
    if (ownedBackgrounds.contains(id)) {
      selectedBackground = id;
      notifyListeners();
      save();
    }
  }

  bool buyBackground(String id, int price) {
    if (coins >= price && !ownedBackgrounds.contains(id)) {
      coins -= price;
      ownedBackgrounds.add(id);
      selectedBackground = id;
      notifyListeners();
      save();
      return true;
    }
    return false;
  }

  // === Достижения ===
  bool isAchievementCollected(int index) => collectedAchievements.contains(index);

  void collectAchievement(int index, int reward) {
    if (!collectedAchievements.contains(index)) {
      coins += reward;
      collectedAchievements.add(index);
      notifyListeners();
      save();
    }
  }
}