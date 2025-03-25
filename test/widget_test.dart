import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurture_sync/main.dart';
import 'package:nurture_sync/features/auth/screens/login_screen.dart';
import 'package:nurture_sync/core/widgets/custom_button.dart';
import 'package:nurture_sync/features/auth/widgets/input_fields.dart';
import 'package:nurture_sync/features/auth/widgets/social_auth_buttons.dart';
import 'package:nurture_sync/features/auth/screens/splash_screen.dart';
import 'package:nurture_sync/core/widgets/logo_animation.dart';

void main() {
  
    testWidgets('CustomButton displays text and responds to tap', (WidgetTester tester) async {
      bool buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                buttonTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(buttonTapped, isTrue);
    });

    testWidgets('CustomTextField displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Test Field',
              obscureText: false,
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

}