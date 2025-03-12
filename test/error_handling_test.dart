import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/pdf_viewer_screen.dart';
import 'package:my_pdf/utils/error_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'error_handling_test.mocks.dart';

@GenerateMocks([PdfErrorHandler])
void main() {
  setUp(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Password-protected PDF shows password dialog', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Simulate a password-protected PDF
    pdfProvider.simulatePasswordProtectedPdf();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        // Add localization support for the tests
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );
    
    // Wait for the password dialog to appear
    await tester.pumpAndSettle();
    
    // Verify that the password dialog is displayed
    expect(find.text('Password Required'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    
    // Enter the password
    await tester.enterText(find.byType(TextField), 'password');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    
    // Verify that the password dialog is dismissed
    expect(find.text('Password Required'), findsNothing);
  });

  testWidgets('Corrupt PDF shows error dialog', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Simulate a corrupt PDF
    pdfProvider.simulateCorruptPdf();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        // Add localization support for the tests
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );
    
    // Wait for the error dialog to appear
    await tester.pumpAndSettle();
    
    // Verify that the error dialog is displayed
    expect(find.text('Corrupt PDF'), findsOneWidget);
    expect(find.text('Continue Anyway'), findsOneWidget);
    expect(find.text('Go Back'), findsOneWidget);
    
    // Tap "Continue Anyway"
    await tester.tap(find.text('Continue Anyway'));
    await tester.pumpAndSettle();
    
    // Verify that the error dialog is dismissed
    expect(find.text('Corrupt PDF'), findsNothing);
  });

  testWidgets('Large PDF shows warning dialog', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Simulate a large PDF
    pdfProvider.simulateLargePdf();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        // Add localization support for the tests
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );
    
    // Wait for the warning dialog to appear
    await tester.pumpAndSettle();
    
    // Verify that the warning dialog is displayed
    expect(find.text('Large File'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    
    // Tap "Continue"
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    
    // Verify that the warning dialog is dismissed
    expect(find.text('Large File'), findsNothing);
  });

  testWidgets('Unsaved changes shows draft dialog on reopen', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Set a current file
    pdfProvider.setCurrentFile('/path/to/test.pdf');
    
    // Set the draft flag directly instead of using mocks
    pdfProvider.setHasDraft(true);
    pdfProvider.setDraftTimestamp(DateTime.now());

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        // Add localization support for the tests
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );
    
    // Wait for the draft dialog to appear
    await tester.pumpAndSettle();
    
    // Verify that the draft dialog is displayed
    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    
    // Tap "Resume"
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    
    // Verify that the draft dialog is dismissed
    expect(find.text('Unsaved Changes'), findsNothing);
  });
} 