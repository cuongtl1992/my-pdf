import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PDF Viewer Screen renders with correct app bar', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );

    // Verify that the PDF viewer screen is displayed
    expect(find.byType(PdfViewerScreen), findsOneWidget);
    
    // Verify that the app bar is displayed
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('PDF Viewer'), findsOneWidget);
    
    // Verify that the share button is displayed
    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('PDF Viewer Screen has editing buttons in bottom app bar', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PdfProvider>.value(
          value: pdfProvider,
          child: const PdfViewerScreen(),
        ),
      ),
    );

    // Verify that the bottom app bar is displayed
    expect(find.byType(BottomAppBar), findsOneWidget);
    
    // Verify that the editing buttons are displayed
    expect(find.byIcon(Icons.text_format), findsOneWidget); // Annotation
    expect(find.byIcon(Icons.highlight), findsOneWidget); // Highlight
    expect(find.byIcon(Icons.delete), findsOneWidget); // Delete page
    expect(find.byIcon(Icons.save), findsOneWidget); // Save
  });

  test('PdfProvider correctly manages page navigation', () async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Set a sample PDF
    const testPdfPath = 'assets/samples/sample.pdf';
    pdfProvider.setAssetPdf(testPdfPath);
    
    // Verify initial page is 0
    expect(pdfProvider.currentPage, 0);
    
    // Set current page to 2
    pdfProvider.setCurrentPage(2);
    expect(pdfProvider.currentPage, 2);
    
    // Test next page
    pdfProvider.setCurrentPage(1);
    expect(pdfProvider.currentPage, 1);
    
    // Test previous page
    pdfProvider.setCurrentPage(0);
    expect(pdfProvider.currentPage, 0);
  });
} 