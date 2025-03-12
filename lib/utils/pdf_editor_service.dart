import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/pdf_edit_operation.dart';

/// Service class for handling PDF editing operations
class PdfEditorService {
  /// Adds a text annotation to a PDF document
  static Future<File> addAnnotation(
    String filePath,
    AnnotationOperation operation,
  ) async {
    // Load the PDF document
    final File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      // Get the page
      final PdfPage page = document.pages[operation.pageIndex];
      
      // Create a text markup annotation (simpler than full annotation)
      final PdfRectangleAnnotation annotation = PdfRectangleAnnotation(
        Rect.fromLTWH(
          operation.position.dx,
          operation.position.dy,
          150, // Default width
          100, // Default height
        ),
        operation.text,
      );
      
      // Set properties
      annotation.opacity = 0.8;
      annotation.border = PdfAnnotationBorder(1);
      annotation.color = PdfColor(
        operation.color.red,
        operation.color.green,
        operation.color.blue,
      );
      
      // Add the annotation to the page
      page.annotations.add(annotation);
      
      // Save the document to a new file
      return await _saveDocument(document, filePath);
    } finally {
      // Close the document
      document.dispose();
    }
  }

  /// Highlights text in a PDF document
  static Future<File> addHighlight(
    String filePath,
    HighlightOperation operation,
  ) async {
    // Load the PDF document
    final File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      // Get the page
      final PdfPage page = document.pages[operation.pageIndex];
      
      // Create a highlight annotation
      final PdfRectangleAnnotation highlight = PdfRectangleAnnotation(
        operation.bounds,
        '',
      );
      
      // Set properties
      highlight.opacity = operation.opacity;
      highlight.color = PdfColor(
        operation.color.red,
        operation.color.green,
        operation.color.blue,
      );
      
      // Add the highlight to the page
      page.annotations.add(highlight);
      
      // Save the document to a new file
      return await _saveDocument(document, filePath);
    } finally {
      // Close the document
      document.dispose();
    }
  }

  /// Deletes a page from a PDF document
  static Future<File> deletePage(
    String filePath,
    DeletePageOperation operation,
  ) async {
    // Load the PDF document
    final File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      // Remove the page
      document.pages.removeAt(operation.pageIndex);
      
      // Save the document to a new file
      return await _saveDocument(document, filePath);
    } finally {
      // Close the document
      document.dispose();
    }
  }

  /// Saves the edited PDF document with a unique filename
  static Future<File> _saveDocument(PdfDocument document, String originalFilePath) async {
    // Generate a unique filename
    final String directory = path.dirname(originalFilePath);
    final String filename = path.basenameWithoutExtension(originalFilePath);
    final String extension = path.extension(originalFilePath);
    
    // Create a pattern like "document_edited(1).pdf"
    String newFilePath;
    int counter = 1;
    
    do {
      newFilePath = path.join(directory, '${filename}_edited($counter)$extension');
      counter++;
    } while (File(newFilePath).existsSync());
    
    // Save the document
    final List<int> bytes = await document.save();
    final File newFile = File(newFilePath);
    await newFile.writeAsBytes(bytes);
    
    return newFile;
  }
  
  /// Saves the edited PDF document with a custom filename
  static Future<File> saveDocumentWithCustomName(
    PdfDocument document, 
    String originalFilePath, 
    String customFilename
  ) async {
    // Get the directory and extension
    final String directory = path.dirname(originalFilePath);
    final String extension = path.extension(originalFilePath);
    
    // Ensure the custom filename has the correct extension
    String sanitizedFilename = customFilename;
    if (!sanitizedFilename.toLowerCase().endsWith('.pdf')) {
      sanitizedFilename = '$sanitizedFilename$extension';
    }
    
    // Create the full path
    String newFilePath = path.join(directory, sanitizedFilename);
    
    // If the file already exists, add a counter
    int counter = 1;
    while (File(newFilePath).existsSync()) {
      final String filenameWithoutExt = path.basenameWithoutExtension(sanitizedFilename);
      newFilePath = path.join(directory, '${filenameWithoutExt}($counter)$extension');
      counter++;
    }
    
    // Save the document
    final List<int> bytes = await document.save();
    final File newFile = File(newFilePath);
    await newFile.writeAsBytes(bytes);
    
    return newFile;
  }
  
  /// Saves the edited PDF document with a custom filename from operations
  static Future<File> saveEditedPdfWithCustomName(
    String originalFilePath,
    List<PdfEditOperation> operations,
    String customFilename
  ) async {
    if (operations.isEmpty) {
      // If no operations, just copy the file with the new name
      final File originalFile = File(originalFilePath);
      final String directory = path.dirname(originalFilePath);
      final String extension = path.extension(originalFilePath);
      
      // Ensure the custom filename has the correct extension
      String sanitizedFilename = customFilename;
      if (!sanitizedFilename.toLowerCase().endsWith('.pdf')) {
        sanitizedFilename = '$sanitizedFilename$extension';
      }
      
      final String newFilePath = path.join(directory, sanitizedFilename);
      final File newFile = File(newFilePath);
      
      if (await newFile.exists()) {
        // If file exists, use the counter approach
        int counter = 1;
        String uniqueFilePath;
        final String filenameWithoutExt = path.basenameWithoutExtension(sanitizedFilename);
        
        do {
          uniqueFilePath = path.join(directory, '${filenameWithoutExt}($counter)$extension');
          counter++;
        } while (File(uniqueFilePath).existsSync());
        
        return await originalFile.copy(uniqueFilePath);
      } else {
        return await originalFile.copy(newFilePath);
      }
    }
    
    // Load the PDF document
    final File file = File(originalFilePath);
    final Uint8List bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    
    try {
      // Apply each operation in sequence
      for (final operation in operations) {
        if (operation is AnnotationOperation) {
          // Get the page
          final PdfPage page = document.pages[operation.pageIndex];
          
          // Create a text markup annotation
          final PdfRectangleAnnotation annotation = PdfRectangleAnnotation(
            Rect.fromLTWH(
              operation.position.dx,
              operation.position.dy,
              150, // Default width
              100, // Default height
            ),
            operation.text,
          );
          
          // Set properties
          annotation.opacity = 0.8;
          annotation.border = PdfAnnotationBorder(1);
          annotation.color = PdfColor(
            operation.color.red,
            operation.color.green,
            operation.color.blue,
          );
          
          // Add the annotation to the page
          page.annotations.add(annotation);
        } else if (operation is HighlightOperation) {
          // Get the page
          final PdfPage page = document.pages[operation.pageIndex];
          
          // Create a highlight annotation
          final PdfRectangleAnnotation highlight = PdfRectangleAnnotation(
            operation.bounds,
            '',
          );
          
          // Set properties
          highlight.opacity = operation.opacity;
          highlight.color = PdfColor(
            operation.color.red,
            operation.color.green,
            operation.color.blue,
          );
          
          // Add the highlight to the page
          page.annotations.add(highlight);
        } else if (operation is DeletePageOperation) {
          // Remove the page
          document.pages.removeAt(operation.pageIndex);
        }
      }
      
      // Save the document with the custom filename
      return await saveDocumentWithCustomName(document, originalFilePath, customFilename);
    } finally {
      // Close the document
      document.dispose();
    }
  }
} 