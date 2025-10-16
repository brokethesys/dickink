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
      "options": ["H2O", "CO2", "O2", "H2"],
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
    // берём вопрос по номеру уровня
    question = questions[widget.level % questions.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002C58),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003974),
        title: Text('Уровень ${widget.level}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              question["question"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Варианты ответов
            ...List.generate(question["options"].length, (index) {
              final isCorrect = index == question["answer"];
              final isSelected = selectedIndex == index;

              Color color = Colors.white;
              if (answered && isSelected) {
                color = isCorrect ? Colors.greenAccent : Colors.redAccent;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  onTap: answered
                      ? null
                      : () {
                          setState(() {
                            selectedIndex = index;
                            answered = true;
                          });
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Text(
                      question["options"][index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
