import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({super.key}); // Key is passed directly to the superclass

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/logo_animation.json', // Ensure this file is added to your assets
      height: 300,
    );
  }
}
