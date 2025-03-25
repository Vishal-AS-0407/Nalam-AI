import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nurture_sync/features/auth/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nurture Sync',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Stack(
        children: [
          // Your existing splash screen
          const SplashScreen(), // Add the VoiceAssistant widget on top
        ],
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}
