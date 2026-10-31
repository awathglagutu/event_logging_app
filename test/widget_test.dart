import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:event_logging_app/main.dart';

void main() {
  testWidgets('shows participants dashboard and registers a participant', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Dashboard home screen elements
    expect(find.text('Participants'), findsOneWidget);
    expect(find.text('No participants yet'), findsOneWidget);
    expect(find.text('New participant'), findsOneWidget);

    // Tap the FAB to register a new participant
    await tester.tap(find.text('New participant'));
    await tester.pumpAndSettle();

    // Verify registration dialog
    expect(find.text('New Participant'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Participant should now appear in the list
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('0 event logs · 0 surveys'), findsOneWidget);

    // Tap on Alice to open profile page
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    // Profile page elements
    expect(find.text('Add Event Log'), findsOneWidget);
    expect(find.text('Add NASA-TLX Survey'), findsOneWidget);
    expect(find.text('Event Logs (0)'), findsOneWidget);
    expect(find.text('NASA-TLX (0)'), findsOneWidget);

    // Test Add NASA-TLX starts directly on Question 1 without name prompt
    await tester.tap(find.text('Add NASA-TLX Survey'));
    await tester.pumpAndSettle();
    expect(find.text('QUESTION 1 OF 6'), findsOneWidget);
    expect(find.text('How mentally demanding was the task?'), findsOneWidget);
    expect(find.text('YOUR NAME'), findsNothing);

    // Navigate back to profile
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Test Add Event Log has timer immediately unlocked and no person name field
    await tester.tap(find.text('Add Event Log'));
    await tester.pumpAndSettle();
    expect(find.text('New event sheet'), findsOneWidget);
    expect(find.text('Person name'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });
}
