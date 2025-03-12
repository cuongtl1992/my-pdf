import 'dart:convert';
import 'package:flutter/material.dart';
import 'pdf_edit_operation.dart';

/// Model class for storing PDF draft state
class PdfDraft {
  final String filePath;
  final List<PdfEditOperation> operations;
  final int currentPage;
  final DateTime timestamp;

  PdfDraft({
    required this.filePath,
    required this.operations,
    required this.currentPage,
    required this.timestamp,
  });

  /// Create from JSON
  factory PdfDraft.fromJson(Map<String, dynamic> json) {
    final List<dynamic> operationsJson = json['operations'] as List<dynamic>;
    final List<PdfEditOperation> operations = [];

    for (final opJson in operationsJson) {
      final String type = opJson['type'] as String;
      final int pageIndex = opJson['pageIndex'] as int;

      if (type == 'annotation') {
        operations.add(
          AnnotationOperation(
            pageIndex: pageIndex,
            text: opJson['text'] as String,
            position: Offset(
              opJson['positionX'] as double,
              opJson['positionY'] as double,
            ),
            color: Color(opJson['color'] as int),
          ),
        );
      } else if (type == 'highlight') {
        operations.add(
          HighlightOperation(
            pageIndex: pageIndex,
            bounds: Rect.fromLTWH(
              opJson['left'] as double,
              opJson['top'] as double,
              opJson['width'] as double,
              opJson['height'] as double,
            ),
            color: Color(opJson['color'] as int),
            opacity: opJson['opacity'] as double,
          ),
        );
      } else if (type == 'delete') {
        operations.add(
          DeletePageOperation(
            pageIndex: pageIndex,
          ),
        );
      }
    }

    return PdfDraft(
      filePath: json['filePath'] as String,
      operations: operations,
      currentPage: json['currentPage'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> operationsJson = [];

    for (final op in operations) {
      if (op is AnnotationOperation) {
        operationsJson.add({
          'type': 'annotation',
          'pageIndex': op.pageIndex,
          'text': op.text,
          'positionX': op.position.dx,
          'positionY': op.position.dy,
          'color': op.color.value,
        });
      } else if (op is HighlightOperation) {
        operationsJson.add({
          'type': 'highlight',
          'pageIndex': op.pageIndex,
          'left': op.bounds.left,
          'top': op.bounds.top,
          'width': op.bounds.width,
          'height': op.bounds.height,
          'color': op.color.value,
          'opacity': op.opacity,
        });
      } else if (op is DeletePageOperation) {
        operationsJson.add({
          'type': 'delete',
          'pageIndex': op.pageIndex,
        });
      }
    }

    return {
      'filePath': filePath,
      'operations': operationsJson,
      'currentPage': currentPage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON string
  static PdfDraft? fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return PdfDraft.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing PDF draft: $e');
      return null;
    }
  }
} 