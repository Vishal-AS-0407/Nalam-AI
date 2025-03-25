import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';
import 'package:nurture_sync/features/health_track/screens/home_screen.dart';

void main() => runApp(const NurtureSyncApp());

class NurtureSyncApp extends StatelessWidget {
  const NurtureSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF008080),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const IntroPage1(),
    );
  }
}

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StyledButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class FadeTransitionWidget extends StatelessWidget {
  final Widget child;

  const FadeTransitionWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'appLogo',
              child: SizedBox(
                height: 100,
                child: Image.asset('assets/images/NS logo.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransitionWidget(
              child: const Text(
                'Welcome to Nurture Sync',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Lottie.asset('assets/animations/agent.json', height: 200),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Get Started',
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const IntroPage2(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'Track Your Health Metrics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'Stay informed about your vitals and patterns.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/graphs.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Next',
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const IntroPage3(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'Personalized Guidance',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'Get tailored insights and recommendations for your health goals.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/ai analysis.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Next',
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const IntroPage4(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage4 extends StatelessWidget {
  const IntroPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'Connect with a Community',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'Join like-minded individuals on their health journey.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/network2.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Next',
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const IntroPage5(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage5 extends StatelessWidget {
  const IntroPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'Digital Health profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'No need to carry reports and precriptions for consultation just share your profile with doctor',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/a3.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Next',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const IntroPage6(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage6 extends StatelessWidget {
  const IntroPage6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'AI Voice Assistant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'Write Posts, Register for events, Get personalized guidance and many just with a voice command',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/voice.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Next',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const IntroPage7(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage7 extends StatelessWidget {
  const IntroPage7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransitionWidget(
              child: const Text(
                'Ready to Begin?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransitionWidget(
              child: Text(
                'Start tracking your health journey with Nurture Sync today! Join the community Now ⚡',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006E7F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Lottie.asset('assets/animations/a2.json', height: 300),
            const SizedBox(height: 30),
            StyledButton(
              text: 'Let’s Go',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const HomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
