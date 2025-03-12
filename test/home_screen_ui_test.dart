import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/home_screen.dart';

void main() {
  late PdfProvider pdfProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    pdfProvider = PdfProvider();
  });

  testWidgets('HomeScreen shows recent files header', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify the Recent Files header is shown
    expect(find.text('Recent Files'), findsOneWidget);
    expect(find.text('No Recent Files'), findsOneWidget);
  });

  testWidgets('Open PDF button is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify the Open PDF button is shown
    expect(find.text('Open PDF File'), findsOneWidget);
  });

  testWidgets('Sort button is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify the Sort button is shown
    expect(find.text('Sort'), findsOneWidget);
  });

  testWidgets('Search icon is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify the search icon is shown
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('Refresh button is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify the refresh button is shown
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
} 