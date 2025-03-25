import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'package:nurture_sync/features/health_info/health_info_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _professionController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  bool _isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(phone);
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final age = _ageController.text.trim();
    final profession = _professionController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty ||
        age.isEmpty ||
        profession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firebase User ID
      final firebaseUserId = userCredential.user?.uid;

      // Prepare user details for MongoDB
      final userDetails = {
        "id": firebaseUserId ?? "",
        "email": email,
        "full_name": fullName,
        "phone": phone,
        "age": int.parse(age),
        "profession": profession,
        "patient_data": {
          "current_diagnosis": [],
          "medications": [],
          "dietary_preferences": [],
          "exercise_routine": [],
          "health_goals": [],
          "current_symptoms": []
        },
        "created_at": DateTime.now().toIso8601String(),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthInfoPage(userDetails: userDetails),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error occurred during sign up.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password should be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: const Color.fromARGB(255, 217, 240, 244),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/signup.json',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameController,
                  decoration: _inputDecoration("Full Name"),
                  cursorColor: const Color(0xFF006E7F),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email ID"),
                  cursorColor: const Color(0xFF006E7F),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("Phone Number"),
                  cursorColor: const Color(0xFF006E7F),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  cursorColor: const Color(0xFF006E7F),
                  obscureText: true,
                  decoration: _inputDecoration("Password"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color(0xFF006E7F),
                  decoration: _inputDecoration("Age"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _professionController,
                  decoration: _inputDecoration("Profession"),
                  cursorColor: const Color(0xFF006E7F),
                ),
                const SizedBox(height: 15),
                _isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: _signUp,
                        child: _signUpButton(),
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFF006E7F), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF006E7F)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF006E7F), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _signUpButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A0B0), Color(0xFF006E7F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Text(
        "Sign Up",
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
