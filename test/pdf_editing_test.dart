import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_pdf/models/pdf_edit_operation.dart';
import 'package:my_pdf/providers/pdf_provider.dart';
import 'package:my_pdf/utils/pdf_editor_service.dart';

import 'pdf_editing_test.mocks.dart';

// Generate mocks
@GenerateMocks([File])
void main() {
  // Initialize Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('PDF Editing Tests', () {
    late PdfProvider pdfProvider;

    setUp(() {
      pdfProvider = PdfProvider();
    });

    test('Should add annotation operation to edit operations list', () async {
      // Set a mock file path
      pdfProvider.setCurrentFile('/path/to/test.pdf');
      
      // Add an annotation
      await pdfProvider.addAnnotation(
        'Test annotation',
        const Offset(100, 100),
      );
      
      // Verify that the operation was added
      expect(pdfProvider.hasUnsavedChanges, true);
      expect(pdfProvider.canUndo, true);
    });

    test('Should add highlight operation to edit operations list', () async {
      // Set a mock file path
      pdfProvider.setCurrentFile('/path/to/test.pdf');
      
      // Add a highlight
      await pdfProvider.addHighlight(
        const Rect.fromLTWH(100, 100, 200, 50),
      );
      
      // Verify that the operation was added
      expect(pdfProvider.hasUnsavedChanges, true);
      expect(pdfProvider.canUndo, true);
    });

    test('Should add delete page operation to edit operations list', () async {
      // Set a mock file path
      pdfProvider.setCurrentFile('/path/to/test.pdf');
      
      // Delete a page
      await pdfProvider.deletePage();
      
      // Verify that the operation was added
      expect(pdfProvider.hasUnsavedChanges, true);
      expect(pdfProvider.canUndo, true);
    });

    test('Should undo the last operation', () async {
      // Set a mock file path
      pdfProvider.setCurrentFile('/path/to/test.pdf');
      
      // Add an annotation
      await pdfProvider.addAnnotation(
        'Test annotation',
        const Offset(100, 100),
      );
      
      // Verify that the operation was added
      expect(pdfProvider.hasUnsavedChanges, true);
      expect(pdfProvider.canUndo, true);
      
      // Undo the operation
      pdfProvider.undoLastOperation();
      
      // Verify that the operation was undone
      expect(pdfProvider.hasUnsavedChanges, false);
      expect(pdfProvider.canUndo, false);
    });

    test('Should reset editing state when setting a new file', () async {
      // Set a mock file path
      pdfProvider.setCurrentFile('/path/to/test.pdf');
      
      // Add an annotation
      await pdfProvider.addAnnotation(
        'Test annotation',
        const Offset(100, 100),
      );
      
      // Verify that the operation was added
      expect(pdfProvider.hasUnsavedChanges, true);
      
      // Set a new file
      pdfProvider.setCurrentFile('/path/to/another.pdf');
      
      // Verify that the editing state was reset
      expect(pdfProvider.hasUnsavedChanges, false);
      expect(pdfProvider.canUndo, false);
    });
  });

  group('PDF Edit Operations', () {
    test('AnnotationOperation should have correct properties', () {
      const pageIndex = 0;
      const text = 'Test annotation';
      const position = Offset(100, 100);
      const color = Colors.blue;
      
      final operation = AnnotationOperation(
        pageIndex: pageIndex,
        text: text,
        position: position,
        color: color,
      );
      
      expect(operation.pageIndex, pageIndex);
      expect(operation.text, text);
      expect(operation.position, position);
      expect(operation.color, color);
    });

    test('HighlightOperation should have correct properties', () {
      const pageIndex = 0;
      const bounds = Rect.fromLTWH(100, 100, 200, 50);
      const color = Colors.yellow;
      const opacity = 0.5;
      
      final operation = HighlightOperation(
        pageIndex: pageIndex,
        bounds: bounds,
        color: color,
        opacity: opacity,
      );
      
      expect(operation.pageIndex, pageIndex);
      expect(operation.bounds, bounds);
      expect(operation.color, color);
      expect(operation.opacity, opacity);
    });

    test('DeletePageOperation should have correct properties', () {
      const pageIndex = 0;
      
      final operation = DeletePageOperation(
        pageIndex: pageIndex,
      );
      
      expect(operation.pageIndex, pageIndex);
    });
  });
} 