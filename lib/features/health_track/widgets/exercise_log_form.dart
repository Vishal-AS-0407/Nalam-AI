import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseLogForm extends StatefulWidget {
  const ExerciseLogForm({super.key});

  @override
  _ExerciseLogFormState createState() => _ExerciseLogFormState();
}

class _ExerciseLogFormState extends State<ExerciseLogForm> {
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _exerciseTypes = ["Yoga", "Pranayama", "Mudras", "Walking", "Running"];
  String? _selectedExercise;

  Future<void> _logExercise() async {
    final exerciseType = _selectedExercise;
    final duration = int.tryParse(_durationController.text) ?? 0;
    final caloriesBurned = int.tryParse(_caloriesController.text) ?? 0;

    if (exerciseType != null && duration > 0 && caloriesBurned > 0) {
      final log = {
        "id": "1",
        "user_id": "6767f3b1749a78f372d03fe4", // Replace with actual user ID
        "date": DateTime.now().toIso8601String(),
        "exercises": [
          {
            "exercise_type": exerciseType,
            "duration_minutes": duration,
            "calories_burned": caloriesBurned,
            "target_calories": 500, // Example target value
          }
        ],
      };

      final url = Uri.parse('http://192.168.123.247:8000/api/exercise_logs/');
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(log),
        );

        if (response.statusCode == 200) {
          // Clear the form
          setState(() {
            _selectedExercise = null;
            _durationController.clear();
            _caloriesController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Exercise logged successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to log exercise. Try again.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              hint: Text("Select Exercise Type"),
              items: _exerciseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExercise = value;
                });
              },
              icon:
                  const SizedBox.shrink(), // Removes the default dropdown icon
              decoration: InputDecoration(
                labelText: "Exercise Type",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF006D77)),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/icons/down.png', // Replace with your icon path
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: "Duration (minutes)",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF006D77)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: "Calories Burned",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF006D77)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _logExercise,
              child: SizedBox(
                width: 150, // Adjust width as needed
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A0B0), Color(0xFF006E7F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Log Exercise",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
