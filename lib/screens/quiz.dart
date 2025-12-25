import 'dart:convert';
import 'package:flutter/material.dart';

// Simple quiz screen using local JSON seed questions
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int index = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    // Load sample questions from seed (in real app: fetch Firestore or assets)
    questions = jsonDecode(sampleQuestionsJson);
  }

  void answer(bool correct) {
    if (correct) score++;
    setState(() => index++);
  }

  @override
  Widget build(BuildContext context) {
    if (index >= questions.length) {
      return Scaffold(appBar: AppBar(title: const Text('Quiz')), body: Center(child: Text('Score: $score / ${questions.length}')));
    }
    final q = questions[index];
    return Scaffold(
      appBar: AppBar(title: Text('Quiz - ${q['category']}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [Text(q['question']), const SizedBox(height: 12), ...q['options'].map<Widget>((o) => ElevatedButton(onPressed: () => answer(o==q['answer']), child: Text(o))).toList()]),
      ),
    );
  }
}

const sampleQuestionsJson = '''
[
  {"category":"General","question":"What is 2+2?","options":["3","4","5"],"answer":"4"},
  {"category":"Science","question":"Water chemical formula?","options":["H2O","CO2","O2"],"answer":"H2O"}
]
''';
