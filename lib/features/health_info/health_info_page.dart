import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'congrats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthInfoPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  const HealthInfoPage({super.key, required this.userDetails});

  @override
  _HealthInfoPageState createState() => _HealthInfoPageState();
}

class _HealthInfoPageState extends State<HealthInfoPage>
    with SingleTickerProviderStateMixin {
  final _patientData = {
    "current_diagnosis": [],
    "medications": [],
    "dietary_preferences": [],
    "exercise_routine": [],
    "health_goals": [],
    "current_symptoms": []
  };

  final List<Map<String, dynamic>> _questions = [
    {
      "title": "What are your current diagnoses?",
      "options": [
        "Hypothyroidism",
        "Hyperthyroidism",
        "Type 1 Diabetes",
        "Type 2 Diabetescurrent_diagnosis",
        "Pre-diabetes",
        "None"
      ],
      "field": "current_diagnosis"
    },
    {
      "title": "Are you taking any medications?",
      "options": [
        "Insulin",
        "Metformin",
        "Thyroid Hormone Replacement",
        "Sulfonylureas",
        "None"
      ],
      "field": "medications"
    },
    {
      "title": "What are your dietary preferences?",
      "options": [
        "Vegetarian",
        "Vegan",
        "Low-Carb",
        "Gluten-Free",
        "No specific preferences"
      ],
      "field": "dietary_preferences"
    },
    {
      "title": "What is your exercise routine?",
      "options": [
        "Daily Exercise",
        "2-3 Times a Week",
        "Occasional Exercise",
        "No Regular Exercise"
      ],
      "field": "exercise_routine"
    },
    {
      "title": "What are your health goals?",
      "options": [
        "Improve Blood Sugar Levels",
        "Lose Weight",
        "Increase Physical Activity",
        "Better Thyroid Management",
        "Other (Please Specify)"
      ],
      "field": "health_goals"
    },
    {
      "title": "What are your current symptoms?",
      "options": [
        "Fatigue",
        "Increased Thirst",
        "Frequent Urination",
        "Weight Changes",
        "None"
      ],
      "field": "current_symptoms"
    }
  ];

  int _currentQuestionIndex = 0;
  List<String> _selectedOptions = [];
  bool _isLoading = false;

  void _nextQuestion() {
    if (_selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option.')),
      );
      return;
    }

    setState(() {
      final field = _questions[_currentQuestionIndex]["field"] as String;
      _patientData[field] = List<String>.from(_selectedOptions);
      _selectedOptions = [];
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitPatientData();
      }
    });
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  Future<void> saveUserDataLocally(Map<String, dynamic> userDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userDetails));
  }

  Future<void> _submitPatientData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final completeData = {
      ...widget.userDetails,
      "patient_data": _patientData,
      "created_at": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.123.247:8000/api/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(completeData),
      );

      if (response.statusCode == 200) {
        await saveUserDataLocally(completeData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileCreatedPage(),
          ),
        );
      } else {
        throw Exception(
            jsonDecode(response.body)["detail"] ?? 'Failed to submit data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF006E7F)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF006E7F), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF006E7F), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F9),
      appBar: AppBar(
        title: const Text('Health Information'),
        centerTitle: true,
        backgroundColor: const Color(0xFF006E7F),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/left.png',
            width: 24,
            height: 24,
            color: Colors.white, // Optional: apply a color overlay
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006E7F)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF006E7F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      question["title"] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006E7F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (question["options"] as List<String>).length,
                      itemBuilder: (context, index) {
                        final option =
                            (question["options"] as List<String>)[index];
                        final isSelected = _selectedOptions.contains(option);
                        return ZoomIn(
                          child: GestureDetector(
                            onTap: () => _toggleOption(option),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF006E7F)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF006E7F),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  BounceInUp(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        backgroundColor: const Color(0xFF006E7F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Next'
                            : 'Submit',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
