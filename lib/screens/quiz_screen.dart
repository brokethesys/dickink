import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    question = questions[widget.level % questions.length];
  }

  void _handleAnswerTap(int index) {
    if (answered) return;
    setState(() {
      selectedIndex = index;
      answered = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Фон
          Positioned.fill(
            child: Image.asset(
              'assets/images/quiz_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Тёмный градиент для читаемости текста
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
                        onPressed: () => Navigator.pop(context),
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
                        ),
                      ),
                      const SizedBox(width: 48), // баланс для симметрии
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 🧠 Вопрос
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

                  // 🟩 Варианты ответов — сетка 2x2
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
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  question["options"][index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
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
