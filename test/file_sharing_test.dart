import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/pdf_viewer_screen.dart';
import 'package:my_pdf/utils/file_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'file_sharing_test.mocks.dart';

@GenerateMocks([FileService])
void main() {
  setUp(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Share button in PDF viewer shows share options', (WidgetTester tester) async {
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Set a current file
    pdfProvider.setCurrentFile('/path/to/test.pdf');

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
    
    // Wait for the widget to build
    await tester.pumpAndSettle();
    
    // Find and tap the share button in the app bar
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();
    
    // Verify that the share options are displayed
    expect(find.text('Share PDF'), findsOneWidget);
    expect(find.text('Share File'), findsOneWidget);
    expect(find.text('Open Folder'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Recent files list updates after opening a PDF', (WidgetTester tester) async {
    // Create a temporary file for testing
    final tempDir = await getTemporaryDirectory();
    final samplePdfPath = '${tempDir.path}/sample.pdf';
    
    // Copy the sample PDF from assets to the temporary directory
    final data = await rootBundle.load('assets/samples/sample.pdf');
    final bytes = data.buffer.asUint8List();
    final file = File(samplePdfPath);
    await file.writeAsBytes(bytes);
    
    // Create a PdfProvider
    final pdfProvider = PdfProvider();
    await pdfProvider.initialize();
    
    // Set the current file to the sample PDF
    pdfProvider.setCurrentFile(samplePdfPath);
    
    // Verify that the recent files list is updated
    expect(pdfProvider.recentFiles.length, 1);
    expect(pdfProvider.recentFiles.first.path, samplePdfPath);
    
    // Clean up
    await file.delete();
  });
} 