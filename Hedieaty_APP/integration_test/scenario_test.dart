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

    // Find widgets
    final emailField = find.byKey(const Key('EmailField'));
    final passwordField = find.byKey(const Key('PasswordField'));
    final loginButton = find.byKey(const Key('LoginButton'));

    // Simulate user input with delays
    await tester.enterText(passwordField, '123456');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.enterText(emailField, 'a@gmail.com');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    //login
    await tester.tap(loginButton);

    await tester.pumpAndSettle(const Duration(seconds: 15));



    // Find the event icon
    final eIcon = find.byKey(const Key('eventIcon'));
    await tester.tap(eIcon.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

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
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    await tester.tap(find.text('31').last); // Pick date: 26
    await tester.tap(find.text('31').last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(find.text('OK')); // Confirm date

    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(find.text('OK')); // Confirm time
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

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
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    final addGiftButtonFinder = find.byType(FloatingActionButton);
    expect(addGiftButtonFinder, findsOneWidget);
    await tester.tap(addGiftButtonFinder);
    await tester.pumpAndSettle();

    // Enter event details
    await tester.enterText(find.byKey(const Key('Gift Name')), 'Fish');
    await tester.enterText(find.byKey(const Key('Gift Description')), 'I want fish');
    await tester.enterText(find.byKey(const Key('Price')), '256');

    // Select category
    final dropdownMenu = find.byKey(const Key("Dropdown Category"));
    await tester.tap(dropdownMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food/Gourmet Item').last);
    await tester.pumpAndSettle();

    final addButton = find.byKey(const Key('Add Button'));
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));

    //Looping until the gift gets pledged or un pledged
    final giftCard = find.byKey(const Key("giftCard")).first;

    // Wait until the color of the gift card changes
    Color? initialColor;
    bool colorChanged = false;

    while (!colorChanged) {
      // Retrieve the widget to check its color
      final giftCardWidget = tester.widget<Card>(giftCard);

      // Assuming the gift card has a color property, e.g., giftCardWidget.color
      final currentColor = giftCardWidget.color;

      if (initialColor == null) {
        initialColor = currentColor; // Set the initial color
      } else if (initialColor != currentColor) {
        colorChanged = true; // Color has changed
      }

      // Pump the tester to allow the UI to update
      await tester.pumpAndSettle();

      // Optional: Add a delay to avoid rapid looping
      await Future.delayed(const Duration(milliseconds: 100));
    }


    await Future.delayed(const Duration(seconds: 10));

  });
}

