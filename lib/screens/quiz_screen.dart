import 'package:flutter/material.dart';
import '../main.dart'; // для currentBackground

class QuizScreen extends StatefulWidget {
  final int level;
  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Map<String, dynamic> question;
  int? selectedIndex;
  bool answered = false;
  Color backgroundColor = Colors.blue;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Какой химический элемент обозначается символом Na?",
      "options": ["Натрий", "Азот", "Никель", "Неон"],
      "answer": 0
    },
    {
      "question": "Какая формула воды?",
      "options": ["H₂O", "CO₂", "O₂", "H₂"],
      "answer": 0
    },
    {
      "question": "Какой газ является основным компонентом воздуха?",
      "options": ["Кислород", "Азот", "Углекислый газ", "Водород"],
      "answer": 1
    },
    {
      "question": "Какой элемент имеет атомный номер 1?",
      "options": ["Гелий", "Водород", "Литий", "Кислород"],
      "answer": 1
    },
  ];

  Color _colorForId(String id) {
    final colorMap = {
      'blue': Colors.blue,
      'green': Colors.green,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'red': Colors.red,
      'cyan': Colors.cyan,
      'pink': Colors.pink,
      'teal': Colors.teal,
    };
    return colorMap[id] ?? Colors.blue;
  }

  void _backgroundListener() {
    setState(() {
      backgroundColor = _colorForId(currentBackground.value);
    });
  }

  @override
  void initState() {
    super.initState();
    question = questions[widget.level % questions.length];

    // Инициализация фона
    backgroundColor = _colorForId(currentBackground.value);

    // Подписка на изменения фона
    currentBackground.addListener(_backgroundListener);
  }

  @override
  void dispose() {
    currentBackground.removeListener(_backgroundListener);
    super.dispose();
  }

  void _handleAnswerTap(int index) {
    if (answered) return;

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    final isCorrect = index == question["answer"];

    // Через секунду возвращаем результат
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Фон с выбранным цветом
          Positioned.fill(
            child: Container(color: backgroundColor),
          ),

          // 🔹 Градиент для читаемости
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.2),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 🔹 Содержимое
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Верхняя панель
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                      ),
                      Text(
                        'Уровень ${widget.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Вопрос
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      question["question"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Варианты ответов (2x2)
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: question["options"].length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final isCorrect = index == question["answer"];
                        final isSelected = selectedIndex == index;

                        Color borderColor = Colors.white;
                        Color fillColor = Colors.white.withOpacity(0.1);

                        // Подсветка при ответе
                        if (answered && isSelected) {
                          borderColor =
                              isCorrect ? Colors.greenAccent : Colors.redAccent;
                          fillColor = borderColor.withOpacity(0.3);
                        } else if (answered && isCorrect) {
                          borderColor = Colors.greenAccent;
                        }

                        return GestureDetector(
                          onTap: () => _handleAnswerTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 3),
                            ),
                            child: Center(
                              child: AnimatedScale(
                                scale: isSelected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  question["options"][index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black45,
                                          blurRadius: 4),
                                    ],
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}