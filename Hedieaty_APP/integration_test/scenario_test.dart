import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  testWidgets('Login integration test', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Find widgets
    final emailField = find.byKey(const Key('EmailField'));
    final passwordField = find.byKey(const Key('PasswordField'));
    final loginButton = find.byKey(const Key('LoginButton'));

    // Simulate user input with delays
    await tester.enterText(passwordField, '123456');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(emailField, 'a@gmail.com');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    //login
    await tester.tap(loginButton);

    await tester.pumpAndSettle(const Duration(seconds: 15));


    // Find the event icon
    final eIcon = find.byKey(const Key('eventIcon'));
    await tester.tap(eIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //Add event
    // Tap on the add button
    final addButtonFinder = find.byType(FloatingActionButton);
    expect(addButtonFinder, findsOneWidget);
    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    // Enter event details
    await tester.enterText(find.byKey(const Key('Event Name')), 'Birthday');
    await tester.enterText(find.byKey(const Key('Location')), 'Home');
    await tester.enterText(find.byKey(const Key('Description')), 'My birthday love you all');

    // Select category
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday').last);
    await tester.pumpAndSettle();

    // Pick date and time
    await tester.tap(find.text('Pick Date & Time'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('31').last); // Pick date: 26
    await tester.tap(find.text('31').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('OK')); // Confirm date

    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('OK')); // Confirm time
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Submit the form
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final upcomingButton = find.text("Upcoming");
    await tester.tap(upcomingButton);
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();


    // Find the gift icon
    final giftIcon = find.byKey(const Key('giftIcon'));
    await tester.tap(giftIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));


  });
}

