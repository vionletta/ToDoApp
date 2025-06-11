// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_firebase/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_todo_firebase/firebase_options.dart';

void main() {
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that login screen is shown
    expect(find.text('TODO APP'), findsOneWidget);
    expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);

    // Test form interaction
    await tester.enterText(
      find.byKey(const Key('email_field')), 
      'test@example.com'
    );
    await tester.enterText(
      find.byKey(const Key('password_field')), 
      'password123'
    );
    await tester.pumpAndSettle();

    // Verify text was entered
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);

    // Test navigation to register screen
    await tester.tap(find.text('Daftar di sini'));
    await tester.pumpAndSettle();

    // Verify register screen is shown
    expect(find.text('Daftar untuk mulai'), findsOneWidget);
  });
}
