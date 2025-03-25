import 'package:flutter/material.dart';
import '../../../core/widgets/logo_animation.dart';

class SplashScreen extends StatelessWidget {
  // Pass the key directly to the super constructor
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a StatefulWidget to handle the async gap safely
    Future.delayed(const Duration(seconds: 3), () {
      // Ensure the widget is still mounted before accessing the context
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      backgroundColor: Colors.teal[100],
      body: const Center(
        child: LogoAnimation(),
      ),
    );
  }
}
