import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_pdf/models/recent_file.dart';
import 'package:my_pdf/providers/pdf_provider.dart';

import 'file_management_test.mocks.dart';

// Generate mocks
@GenerateMocks([SharedPreferences])
void main() {
  late PdfProvider pdfProvider;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({});
    pdfProvider = PdfProvider();
  });

  group('Recent Files Management', () {
    test('Adding a file to recent files', () async {
      // Add a file
      await pdfProvider.addToRecentFiles('/path/to/test.pdf');
      
      // Verify the file was added
      expect(pdfProvider.recentFiles.length, 1);
      expect(pdfProvider.recentFiles.first.path, '/path/to/test.pdf');
    });

    test('Removing a file from recent files', () async {
      // Add a file first
      await pdfProvider.addToRecentFiles('/path/to/test.pdf');
      
      // Remove the file
      await pdfProvider.removeFromRecentFiles('/path/to/test.pdf');
      
      // Verify the file was removed
      expect(pdfProvider.recentFiles.length, 0);
    });

    test('Recent files list is limited to 10 files', () async {
      // Add 11 files
      for (int i = 0; i < 11; i++) {
        await pdfProvider.addToRecentFiles('/path/to/test$i.pdf');
      }
      
      // Verify only 10 files are kept
      expect(pdfProvider.recentFiles.length, 10);
      
      // Verify the first file added was removed (oldest)
      expect(
        pdfProvider.recentFiles.any((file) => file.path == '/path/to/test0.pdf'),
        false,
      );
    });

    // Skip the search test for now as it requires mocking File.existsSync
    test('Sorting recent files by date', () async {
      // Add files with different dates
      final now = DateTime.now();
      
      // Add files to provider
      await pdfProvider.addToRecentFiles('/path/to/older.pdf');
      // Add a delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));
      await pdfProvider.addToRecentFiles('/path/to/newer.pdf');
      
      // Sort by date (descending - newest first)
      pdfProvider.sortRecentFilesByDate(ascending: false);
      
      // Verify newest is first
      expect(pdfProvider.recentFiles.first.path, '/path/to/newer.pdf');
      
      // Sort by date (ascending - oldest first)
      pdfProvider.sortRecentFilesByDate(ascending: true);
      
      // Verify oldest is first
      expect(pdfProvider.recentFiles.first.path, '/path/to/older.pdf');
    });
  });
} 