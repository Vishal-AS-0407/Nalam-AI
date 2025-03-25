import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password.dart';
import 'signup_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurture_sync/features/health_track/screens/home_screen.dart';
import 'dart:math' show pow;
import 'package:firebase_app_check/firebase_app_check.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _getAppCheckToken() async {
    try {
      return await FirebaseAppCheck.instance.getToken();
    } catch (e) {
      print('Error getting App Check token: $e');
      return null;
    }
  }

  Future<void> _fetchAndStoreUserData(String email) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        final appCheckToken = await _getAppCheckToken();

        final response = await http.get(
          Uri.parse('http://192.168.123.247:8000/api/users/user/$email'),
          headers: {
            "Content-Type": "application/json",
            if (appCheckToken != null) "X-Firebase-AppCheck": appCheckToken,
          },
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', jsonEncode(userData));
          return;
        } else {
          throw Exception('Failed to fetch user data');
        }
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error after $maxAttempts attempts: $e")),
            );
          }
          return;
        }
        // Exponential backoff
        await Future.delayed(Duration(seconds: pow(2, attempts).toInt()));
      }
    }
  }

  // Email/Password Login
  void _login() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email")),
      );
      return;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _fetchAndStoreUserData(_emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );

      // Navigate to HealthTrackApp after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      // Navigate to home or dashboard (not implemented)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

// Google Sign-In
  Future<void> _googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn(); // Ensure a fresh GoogleSignIn instance
      await googleSignIn
          .signOut(); // Sign out to ensure the account selection dialog is shown

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);
      await _fetchAndStoreUserData(googleUser.email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In Successful!")),
      );

      // Navigate to HealthTrackApp after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: const Color.fromARGB(255, 217, 240, 244),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'assets/animations/login.json', // Replace with your animation path
                    width: 350,
                    height: 350,
                  ),
                  const SizedBox(height: 20),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email ID",
                      labelStyle: const TextStyle(color: Color(0xFF006E7F)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Color(0xFF006E7F)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  GestureDetector(
                    onTap: _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00A0B0),
                            Color(0xFF006E7F)
                          ], // Gradient with shades of blue
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  GestureDetector(
                    onTap: _googleSignIn,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/google_icon.png', // Add a Google logo in your assets
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Forgot Password Redirect
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text("Forgot Password?",
                        style: TextStyle(color: Color(0xFF006E7F))),
                  ),

                  // Sign-Up Redirect
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Sign up.",
                        style: TextStyle(color: Color(0xFF006E7F))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
