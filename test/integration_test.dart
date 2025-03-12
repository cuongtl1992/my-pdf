import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_pdf/main.dart' as app;
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/home_screen.dart';
import 'package:my_pdf/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('End-to-end user journey test', (WidgetTester tester) async {
    // Load the app
    app.main();
    await tester.pumpAndSettle();

    // Verify that the home screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('My PDF'), findsOneWidget);

    // Simulate opening a sample PDF
    // First, we need to copy a sample PDF to the device's temporary directory
    final tempDir = await getTemporaryDirectory();
    final samplePdfPath = '${tempDir.path}/sample.pdf';
    
    // Copy the sample PDF from assets to the temporary directory
    final data = await rootBundle.load('assets/samples/sample.pdf');
    final bytes = data.buffer.asUint8List();
    final file = File(samplePdfPath);
    await file.writeAsBytes(bytes);

    // Get the PdfProvider using Provider.of instead of trying to extract it from the widget
    final BuildContext context = tester.element(find.byType(HomeScreen));
    final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
    
    // Set the current file to the sample PDF
    pdfProvider.setCurrentFile(samplePdfPath);

    // Tap on the "Open PDF" button
    await tester.tap(find.text('Open PDF'));
    await tester.pumpAndSettle();

    // Verify that the PDF viewer screen is displayed
    expect(find.byType(PdfViewerScreen), findsOneWidget);

    // Test navigation: swipe to next page
    await tester.drag(find.byType(PdfViewerScreen), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(pdfProvider.currentPage, 1);

    // Test navigation: swipe to previous page
    await tester.drag(find.byType(PdfViewerScreen), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(pdfProvider.currentPage, 0);

    // Test editing: enter editing mode
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(pdfProvider.isEditing, true);

    // Test annotation
    await tester.tap(find.byIcon(Icons.text_format));
    await tester.pumpAndSettle();
    
    // Enter annotation text
    await tester.enterText(find.byType(TextField), 'Test annotation');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    
    // Tap on the PDF to add the annotation
    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle();
    expect(pdfProvider.hasUnsavedChanges, true);

    // Test highlighting
    await tester.tap(find.byIcon(Icons.highlight));
    await tester.pumpAndSettle();
    
    // Simulate text selection for highlighting
    await tester.tapAt(const Offset(200, 400));
    await tester.pumpAndSettle();
    expect(pdfProvider.isHighlighting, true);

    // Test page deletion
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    
    // Confirm deletion
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(pdfProvider.hasUnsavedChanges, true);

    // Test undo
    await tester.tap(find.byIcon(Icons.undo));
    await tester.pumpAndSettle();
    
    // Test saving
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    
    // Enter a filename
    await tester.enterText(find.byType(TextField), 'edited_sample');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    
    // Verify that we're back to the PDF viewer
    expect(find.byType(PdfViewerScreen), findsOneWidget);
    expect(pdfProvider.hasUnsavedChanges, false);

    // Go back to the home screen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    
    // Verify that the home screen is displayed with the recent file
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('edited_sample.pdf'), findsOneWidget);

    // Test error handling: password-protected PDF
    // This would require a password-protected PDF file, which we'll simulate
    pdfProvider.simulatePasswordProtectedPdf();
    
    // Try to open the password-protected PDF
    await tester.tap(find.text('Open PDF'));
    await tester.pumpAndSettle();
    
    // Verify that the password dialog is displayed
    expect(find.text('Password Required'), findsOneWidget);
    
    // Enter the password
    await tester.enterText(find.byType(TextField), 'password');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    
    // Verify that the PDF viewer is displayed
    expect(find.byType(PdfViewerScreen), findsOneWidget);

    // Clean up: delete the temporary files
    await file.delete();
    final editedFile = File('${tempDir.path}/edited_sample.pdf');
    if (await editedFile.exists()) {
      await editedFile.delete();
    }
  });
} 