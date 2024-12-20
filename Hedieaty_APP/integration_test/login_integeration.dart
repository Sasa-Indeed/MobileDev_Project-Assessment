/*
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:hedieaty_app/pages/login_page.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('LoginScreen Tests', () {
    Future<void> _buildLoginScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
          routes: {
            '/Home': (context) => const Scaffold(key: Key('HomePage')),
            '/signup': (context) => const Scaffold(key: Key('SignupPage')),
          },
        ),
      );
      // Add delay after building the screen
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();
    }

    testWidgets('Login button triggers login functionality', (WidgetTester tester) async {
      await _buildLoginScreen(tester);

      // Find widgets
      final emailField = find.byKey(const Key('EmailField'));
      final passwordField = find.byKey(const Key('PasswordField'));
      final loginButton = find.byKey(const Key('LoginButton'));

      // Verify widgets are present
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Simulate user input with delays
      await tester.enterText(emailField, 'a@gmail.com');
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      await tester.enterText(passwordField, '123456');
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Scroll to ensure login button is visible
      await tester.ensureVisible(loginButton);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Tap the login button
      await tester.tap(loginButton);
      await Future.delayed(const Duration(seconds: 1));

      // Use pumpAndSettle with a custom duration between pumps
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    });

    testWidgets('Shows popup for invalid email', (WidgetTester tester) async {
      await _buildLoginScreen(tester);

      // Find widgets
      final emailField = find.byKey(const Key('EmailField'));
      final passwordField = find.byKey(const Key('PasswordField'));
      final loginButton = find.byKey(const Key('LoginButton'));

      // Simulate invalid email input with delays
      await tester.enterText(emailField, 'invalid-email');
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      await tester.enterText(passwordField, '123456');
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Scroll to ensure login button is visible
      await tester.ensureVisible(loginButton);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Tap the login button
      await tester.tap(loginButton);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify that the invalid email popup appears
      expect(find.byKey(const Key('InvalidEmailPopup')), findsOneWidget);
      expect(find.text('Please enter a valid email address.'), findsOneWidget);

      // Wait to see the popup
      await Future.delayed(const Duration(seconds: 2));

      // Close the popup
      await tester.tap(find.text('OK'));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await _buildLoginScreen(tester);

      // Find password field
      final passwordField = find.byKey(const Key('PasswordField'));
      final visibilityIcon = find.byIcon(Icons.visibility_off);

      // Enter password
      await tester.enterText(passwordField, 'test123');
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Toggle visibility
      await tester.tap(visibilityIcon);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      // Toggle visibility back
      await tester.tap(find.byIcon(Icons.visibility));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate to signup page', (WidgetTester tester) async {
      await _buildLoginScreen(tester);

      // Find and tap signup text
      final signupText = find.text('Signup');
      await tester.ensureVisible(signupText);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();

      await tester.tap(signupText);
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.byKey(const Key('SignupPage')), findsOneWidget);
      await Future.delayed(const Duration(seconds: 4));
    });
  });
}*/
