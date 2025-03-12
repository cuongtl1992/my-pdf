import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/widgets/pdf_editing_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUp(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PDF Editing Toolbar renders correctly when editing is enabled', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Enable editing mode
    pdfProvider.toggleEditingMode();

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
        home: Scaffold(
          body: ChangeNotifierProvider<PdfProvider>.value(
            value: pdfProvider,
            child: const Stack(
              children: [
                SizedBox(height: 500, width: 500),
                PdfEditingToolbar(),
              ],
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Verify that the toolbar is displayed
    expect(find.byType(PdfEditingToolbar), findsOneWidget);
    
    // Verify that the editing buttons are displayed
    expect(find.byIcon(Icons.text_format), findsOneWidget); // Annotation
    expect(find.byIcon(Icons.highlight), findsOneWidget); // Highlight
    expect(find.byIcon(Icons.delete), findsOneWidget); // Delete page
    expect(find.byIcon(Icons.undo), findsOneWidget); // Undo
    expect(find.byIcon(Icons.save), findsOneWidget); // Save
  });

  testWidgets('PDF Editing Toolbar does not render when editing is disabled', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Ensure editing mode is disabled
    pdfProvider.toggleEditingMode();
    pdfProvider.toggleEditingMode(); // Toggle twice to ensure it's off

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
        home: Scaffold(
          body: ChangeNotifierProvider<PdfProvider>.value(
            value: pdfProvider,
            child: const Stack(
              children: [
                SizedBox(height: 500, width: 500),
                PdfEditingToolbar(),
              ],
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Verify that the toolbar is not displayed (it should be a SizedBox.shrink)
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('Annotation button shows dialog when tapped', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Enable editing mode
    pdfProvider.toggleEditingMode();

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
        home: Scaffold(
          body: ChangeNotifierProvider<PdfProvider>.value(
            value: pdfProvider,
            child: const Stack(
              children: [
                SizedBox(height: 500, width: 500),
                PdfEditingToolbar(),
              ],
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Tap the annotation button
    await tester.tap(find.byIcon(Icons.text_format));
    await tester.pumpAndSettle();
    
    // Verify that the annotation dialog is displayed
    expect(find.text('Add Annotation'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Delete page button shows confirmation dialog when tapped', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Enable editing mode
    pdfProvider.toggleEditingMode();

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
        home: Scaffold(
          body: ChangeNotifierProvider<PdfProvider>.value(
            value: pdfProvider,
            child: const Stack(
              children: [
                SizedBox(height: 500, width: 500),
                PdfEditingToolbar(),
              ],
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Tap the delete page button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    
    // Verify that the confirmation dialog is displayed
    expect(find.text('Delete Page'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
} 