import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('Test resumeUnsavedSession and page methods', (WidgetTester tester) async {
    // Build a simple app with English locale
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            
            // Test the resumeUnsavedSession method
            final formattedTime = "10:30 AM";
            final timestamp = DateTime.now();
            final resumeMessage = l10n.resumeUnsavedSession(formattedTime, timestamp);
            expect(resumeMessage, contains(formattedTime));
            
            // Test the page method
            final currentPage = 1;
            final totalPages = 10;
            final pageNumber = 1;
            final pageMessage = l10n.page(currentPage, totalPages, pageNumber);
            expect(pageMessage, contains(currentPage.toString()));
            expect(pageMessage, contains(totalPages.toString()));
            
            return Text(resumeMessage);
          },
        ),
      ),
    );
    
    await tester.pumpAndSettle();
  });
} 