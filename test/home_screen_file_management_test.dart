import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_pdf/models/recent_file.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/home_screen.dart';
import 'package:path/path.dart' as path;

// Mock File class for testing
class MockFile extends Fake implements File {
  final String path;
  
  MockFile(this.path);
  
  @override
  bool existsSync() => true;
  
  @override
  DateTime lastModifiedSync() => DateTime.now();
  
  @override
  int lengthSync() => 1024 * 1024; // 1MB
}

void main() {
  late PdfProvider pdfProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    pdfProvider = PdfProvider();
    
    // Use a proper way to mock File operations
    // Instead of trying to assign to the File class directly
    // We'll handle this in the test methods as needed
  });

  Future<void> addTestFiles(PdfProvider provider) async {
    await provider.addToRecentFiles('/path/to/document1.pdf');
    await provider.addToRecentFiles('/path/to/report.pdf');
    await provider.addToRecentFiles('/path/to/presentation.pdf');
  }

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

  testWidgets('HomeScreen shows recent files', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Initially, there should be no recent files
    expect(find.text('No Recent Files'), findsOneWidget);

    // Add some test files
    await addTestFiles(pdfProvider);
    await tester.pump();

    // Now we should see the files in the list
    expect(find.text('No Recent Files'), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Search functionality filters files', (WidgetTester tester) async {
    // Add test files before building the widget
    await addTestFiles(pdfProvider);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Tap the search icon
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    // Enter search query
    await tester.enterText(find.byType(TextField), 'doc');
    await tester.pump();

    // Verify only matching files are shown
    expect(find.text('document1.pdf'), findsOneWidget);
    expect(find.text('report.pdf'), findsNothing);
    expect(find.text('presentation.pdf'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    // Verify all files are shown again
    expect(find.text('document1.pdf'), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
    expect(find.text('presentation.pdf'), findsOneWidget);
  });

  testWidgets('Swipe to delete removes file from list', (WidgetTester tester) async {
    // Add test files before building the widget
    await addTestFiles(pdfProvider);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify we have 3 files initially
    expect(pdfProvider.recentFiles.length, 3);

    // Swipe to delete the first file
    await tester.drag(find.text('document1.pdf'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify the file was removed
    expect(pdfProvider.recentFiles.length, 2);
    expect(find.text('document1.pdf'), findsNothing);
  });

  testWidgets('Sort button shows sort options', (WidgetTester tester) async {
    // Add test files before building the widget
    await addTestFiles(pdfProvider);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Tap the sort button
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();

    // Verify sort options are shown
    expect(find.text('Most Recent First'), findsOneWidget);
    expect(find.text('Oldest First'), findsOneWidget);

    // Tap on "Oldest First"
    await tester.tap(find.text('Oldest First'));
    await tester.pumpAndSettle();

    // Verify the bottom sheet is closed
    expect(find.text('Most Recent First'), findsNothing);
  });
} 