import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  testWidgets('Login integration test', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));

    final signupButtion = find.byKey(const Key("Signup Button"));
    await tester.tap(signupButtion);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));


    // Enter name
    final nameField = find.bySemanticsLabel("Name");
    await tester.enterText(nameField, "Shalaby");
    await Future.delayed(const Duration(seconds: 5));

    // Select profile image
    final imageSelector = find.text("Select Profile Image");
    await tester.tap(imageSelector);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    final firstImage = find.byKey(const Key("Image")).first;
    await tester.tap(firstImage.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // Enter email
    final emailField = find.bySemanticsLabel("Email");
    await tester.enterText(emailField, "sh@gmail.com");
    await Future.delayed(const Duration(seconds: 2));

    // Enter phone number
    final phoneField = find.bySemanticsLabel("Phone Number");
    await tester.enterText(phoneField, "1234");
    await Future.delayed(const Duration(seconds: 2));


    // Enter password
    final passwordField = find.bySemanticsLabel("Password");
    await tester.enterText(passwordField, "123456");
    await Future.delayed(const Duration(seconds: 2));

    // Enter confirm password
    final confirmPasswordField = find.bySemanticsLabel("Confirm Password");
    await tester.enterText(confirmPasswordField, "123456");
    await Future.delayed(const Duration(seconds: 2));


    // Scroll down to preferences
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -350));
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));

    // Select two preferences
    final preferencesDropdown = find.byKey(const Key("Preferences"));
    await tester.tap(preferencesDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Books").last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(preferencesDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Food/Gourmet Items").last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));


    // Enable notifications
    final notificationsSwitch = find.byType(SwitchListTile);
    await tester.tap(notificationsSwitch);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Tap the signup button
    final signupButton = find.text("Signup");
    await tester.tap(signupButton);
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Find the add friend icon
    final addIcon = find.byKey(const Key('addIcon'));
    await tester.tap(addIcon.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    //Tap add by phone
    await tester.tap(find.text("Phone").last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    //Write the phone number
    final friendInputField = find.byKey(const Key('Add Friend Input'));
    await tester.enterText(friendInputField, '123');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    final friendAddButton = find.byKey(const Key("Add Friend Button"));
    await tester.tap(friendAddButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final okButton = find.text("OK");
    await tester.tap(okButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //Enter friend page
    final friendCard = find.text("Ahmed Mostafa");
    await tester.tap(friendCard);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    final pledgeButton = find.byKey(const Key("Pledge Button"));
    await tester.tap(pledgeButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await Future.delayed(const Duration(seconds: 15));

  });
}

