import 'package:flutter/material.dart';
import '../widgets/exercise_log_form.dart';
import '../widgets/exercise_calendar.dart';
import '../widgets/personalized_plans.dart';

class ExerciseTrackingScreen extends StatelessWidget {
  const ExerciseTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Color(0xFFD9F0F4), // Background color for the summary
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "Exercise Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B4C),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard("Total Calories", "1200"),
                      _buildSummaryCard("Total Time", "300 min"),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFFD9F0F4), // Background color for the calendar
              padding: const EdgeInsets.all(16.0),
              child: ExerciseCalendar(),
            ),
            Container(
              color: Color(0xFFD9F0F4), // Background color for the log form
              padding: const EdgeInsets.all(16.0),
              child: ExerciseLogForm(),
            ),
            Container(
              color: Color(0xFFD9F0F4), // Background color for the log form
              padding: const EdgeInsets.all(16.0),
              child: PersonalizedPlans(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Card(
      elevation: 4,
      shadowColor: Color(0xFF005F73).withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003B4C),
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
