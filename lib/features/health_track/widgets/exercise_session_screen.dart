import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExerciseSessionScreen extends StatefulWidget {
  final String plan;

  const ExerciseSessionScreen({super.key, required this.plan});

  @override
  _ExerciseSessionScreenState createState() => _ExerciseSessionScreenState();
}

class _ExerciseSessionScreenState extends State<ExerciseSessionScreen> {
  final List<String> exerciseAnimations = [
    'assets/animations/ex1/e1.json',
    'assets/animations/ex1/e2.json',
    'assets/animations/ex1/e4.json',
    'assets/animations/ex1/e5.json',
    'assets/animations/ex1/e6.json',
    'assets/animations/ex1/e7.json',
    'assets/animations/ex1/e8.json',
  ];

  final List<String> yogaAnimations = [
    'assets/animations/yoga/y1.json',
    'assets/animations/yoga/y2.json',
    'assets/animations/yoga/y3.json',
    'assets/animations/yoga/y4.json',
  ];

  int currentIndex = 0;
  bool isBreak = false;

  @override
  Widget build(BuildContext context) {
    final animations =
        widget.plan == 'exercise' ? exerciseAnimations : yogaAnimations;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == 'exercise' ? "Exercises" : "Yoga"),
        backgroundColor: Color(0xFF005F73),
      ),
      body: Column(
        children: [
          Expanded(
            child: Lottie.asset(
              animations[currentIndex],
              fit: BoxFit.contain,
            ),
          ),
          if (isBreak)
            Text(
              "Break Time",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003B4C),
              ),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (currentIndex > 0) {
                    setState(() => currentIndex--);
                  }
                },
                child: Text("Previous"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (currentIndex < animations.length - 1) {
                    setState(() => currentIndex++);
                  }
                },
                child: Text(
                    currentIndex == animations.length - 1 ? "Finish" : "Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
