import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'exercise_session_screen.dart';

class PersonalizedPlans extends StatelessWidget {
  const PersonalizedPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Personalized Plans",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003B4C),
          ),
        ),
        SizedBox(height: 20),
        _buildPlanCard(
          context,
          title: "Exercises for You",
          animationPath: 'assets/animations/ex1/e7.json',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExerciseSessionScreen(plan: 'exercise')),
          ),
        ),
        SizedBox(height: 20),
        _buildPlanCard(
          context,
          title: "Yoga for You",
          animationPath: 'assets/animations/yoga/y1.json',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExerciseSessionScreen(plan: 'yoga')),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context,
      {required String title,
      required String animationPath,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Lottie.asset(
                animationPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003B4C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
