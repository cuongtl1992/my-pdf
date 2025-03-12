import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/screens/home_screen.dart';

void main() {
  testWidgets('Home Screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => PdfProvider(),
          child: const HomeScreen(),
        ),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('MyPdf'), findsOneWidget);

    // Verify that the 'Open PDF File' button is displayed
    expect(find.text('Open PDF File'), findsOneWidget);
    expect(find.byIcon(Icons.file_open), findsOneWidget);

    // Verify that the 'Recent Files' header is displayed
    expect(find.text('Recent Files'), findsOneWidget);

    // Verify that the refresh FAB is displayed
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
} 