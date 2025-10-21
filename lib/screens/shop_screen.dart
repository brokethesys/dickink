import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // для доступа к currentBackground

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<String> ownedBackgrounds = ['blue', 'green', 'purple', 'orange'];
  String selectedBackground = 'blue';
  int coins = 0;

  final List<Map<String, dynamic>> backgrounds = [
    {'id': 'blue', 'color': Colors.blue, 'price': 0},
    {'id': 'green', 'color': Colors.green, 'price': 0},
    {'id': 'purple', 'color': Colors.purple, 'price': 0},
    {'id': 'orange', 'color': Colors.orange, 'price': 0},
    {'id': 'red', 'color': Colors.red, 'price': 300},
    {'id': 'cyan', 'color': Colors.cyan, 'price': 400},
    {'id': 'pink', 'color': Colors.pink, 'price': 500},
    {'id': 'teal', 'color': Colors.teal, 'price': 600},
  ];

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 1000;
      selectedBackground = prefs.getString('selectedBackground') ?? 'blue';
      ownedBackgrounds =
          prefs.getStringList('ownedBackgrounds') ?? ['blue', 'green', 'purple', 'orange'];
    });
  }

  Future<void> _saveShopData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setString('selectedBackground', selectedBackground);
    await prefs.setStringList('ownedBackgrounds', ownedBackgrounds);
  }

  void _selectBackground(String id) async {
    if (!ownedBackgrounds.contains(id)) return;
    setState(() {
      selectedBackground = id;
    });
    currentBackground.value = id; // ⚡ моментальное применение
    await _saveShopData();
  }

  void _buyBackground(String id, int price) async {
    if (coins >= price) {
      setState(() {
        coins -= price;
        ownedBackgrounds.add(id);
      });
      await _saveShopData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Фон "$id" успешно куплен!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Недостаточно монет 💰'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items, bool owned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final bg = items[index];
            final bool isSelected = selectedBackground == bg['id'];
            final bool isOwned = ownedBackgrounds.contains(bg['id']);
            final double progress =
                (coins / (bg['price'] == 0 ? 1 : bg['price'])).clamp(0, 1).toDouble();

            return GestureDetector(
              onTap: () {
                if (isOwned) {
                  _selectBackground(bg['id']);
                } else {
                  _buyBackground(bg['id'], bg['price']);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bg['color'],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.amberAccent
                        : Colors.white.withOpacity(0.3),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (!isOwned)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isOwned)
                              Text(
                                isSelected ? 'Выбран' : 'Доступен',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$coins/${bg['price']}',
                                        style: const TextStyle(
                                          color: Colors.amberAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: Image.asset(
                                          'assets/images/coin.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      color: Colors.amberAccent,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownedItems =
        backgrounds.where((bg) => ownedBackgrounds.contains(bg['id'])).toList();
    final lockedItems =
        backgrounds.where((bg) => !ownedBackgrounds.contains(bg['id'])).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF001B33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00264D),
        centerTitle: true,
        title: const Text(
          'Магазин фонов',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Image.asset('assets/images/coin.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSection('Ваши фоны', ownedItems, true),
            const SizedBox(height: 20),
            _buildSection('Недоступные', lockedItems, false),
          ],
        ),
      ),
    );
  }
}