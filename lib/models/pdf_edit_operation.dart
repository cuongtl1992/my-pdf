import 'package:flutter/material.dart';

/// Base class for all PDF edit operations
abstract class PdfEditOperation {
  final int pageIndex;
  
  PdfEditOperation({required this.pageIndex});
  
  // Method to apply the operation to a PDF document
  void apply();
  
  // Method to undo the operation
  void undo();
}

/// Represents a text annotation added to a PDF
class AnnotationOperation extends PdfEditOperation {
  final String text;
  final Offset position;
  final Color color;
  
  AnnotationOperation({
    required super.pageIndex,
    required this.text,
    required this.position,
    this.color = Colors.blue,
  });
  
  @override
  void apply() {
    // Implementation will be in the PDF provider
  }
  
  @override
  void undo() {
    // Implementation will be in the PDF provider
  }
}

/// Represents a text highlight operation
class HighlightOperation extends PdfEditOperation {
  final Rect bounds;
  final Color color;
  final double opacity;
  
  HighlightOperation({
    required super.pageIndex,
    required this.bounds,
    this.color = Colors.yellow,
    this.opacity = 0.5,
  });
  
  @override
  void apply() {
    // Implementation will be in the PDF provider
  }
  
  @override
  void undo() {
    // Implementation will be in the PDF provider
  }
}

/// Represents a page deletion operation
class DeletePageOperation extends PdfEditOperation {
  final int pageIndex;
  
  DeletePageOperation({
    required this.pageIndex,
  }) : super(pageIndex: pageIndex);
  
  @override
  void apply() {
    // Implementation will be in the PDF provider
  }
  
  @override
  void undo() {
    // Implementation will be in the PDF provider
  }
} 