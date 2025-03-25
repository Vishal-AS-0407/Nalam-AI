import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'intro.dart';

class ProfileCreatedPage extends StatelessWidget {
  const ProfileCreatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 217, 240, 244),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/congrats.json', // Replace with the path to your Lottie animation file
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 20),

              // Congratulations Message
              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "Your profile has been successfully created.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Done Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the intro page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          IntroPage1(), // Replace with the entry point of your intro pages
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: const Color(0xFF006E7F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
