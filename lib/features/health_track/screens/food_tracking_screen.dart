import 'package:flutter/material.dart';
import '../widgets/meal_log_form.dart';

class FoodTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 240, 244), // Light blue background
      appBar: AppBar(
        title: Text(
          "Food Tracking",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF006E7F), // Dark teal
      ),
      body: MealLogForm(),
    );
  }
}
