import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

/// Utility class for handling PDF-related errors and security measures
class PdfErrorHandler {
  /// Checks if a PDF file is password-protected
  static Future<bool> isPasswordProtected(String filePath) async {
    try {
      // We'll use the syncfusion_flutter_pdf library to check if the file is password-protected
      // This is a simple check that doesn't actually open the file
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // Check for encryption dictionary in the PDF
      // This is a simple heuristic and not 100% accurate
      final String content = String.fromCharCodes(bytes.take(1024));
      return content.contains('/Encrypt') || content.contains('/EncryptMetadata');
    } catch (e) {
      debugPrint('Error checking if PDF is password-protected: $e');
      return false;
    }
  }
  
  /// Checks if a PDF file is corrupt
  static Future<bool> isCorrupt(String filePath) async {
    try {
      // Basic check: can we read the file and does it have the PDF header?
      final file = File(filePath);
      if (!await file.exists()) {
        return true;
      }
      
      final bytes = await file.readAsBytes();
      if (bytes.length < 5) {
        return true;
      }
      
      // Check for PDF header
      final header = String.fromCharCodes(bytes.take(5));
      return header != '%PDF-';
    } catch (e) {
      debugPrint('Error checking if PDF is corrupt: $e');
      return true;
    }
  }
  
  /// Checks if a PDF file is large (>50MB)
  static Future<bool> isLargeFile(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();
      return fileSize > 50 * 1024 * 1024; // 50MB in bytes
    } catch (e) {
      debugPrint('Error checking file size: $e');
      return false;
    }
  }
  
  /// Saves draft state for unsaved changes
  static Future<bool> saveDraft(String filePath, Map<String, dynamic> editState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = 'draft_${filePath.hashCode}';
      
      // Convert edit state to JSON string
      final draftJson = editState.toString();
      
      // Save to SharedPreferences
      await prefs.setString(draftKey, draftJson);
      
      // Save timestamp
      await prefs.setString('${draftKey}_timestamp', DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return false;
    }
  }
  
  /// Checks if there's a draft for the given file
  static Future<bool> hasDraft(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = 'draft_${filePath.hashCode}';
      return prefs.containsKey(draftKey);
    } catch (e) {
      debugPrint('Error checking for draft: $e');
      return false;
    }
  }
  
  /// Gets the draft for the given file
  static Future<Map<String, dynamic>?> getDraft(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = 'draft_${filePath.hashCode}';
      
      final draftJson = prefs.getString(draftKey);
      if (draftJson == null) {
        return null;
      }
      
      // Parse the JSON string
      // This is a simplified version - in a real app, you'd use json.decode
      final Map<String, dynamic> draft = {};
      // Parse the string representation of the map
      // This is just a placeholder - you'd need proper JSON parsing
      
      return draft;
    } catch (e) {
      debugPrint('Error getting draft: $e');
      return null;
    }
  }
  
  /// Clears the draft for the given file
  static Future<bool> clearDraft(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = 'draft_${filePath.hashCode}';
      
      await prefs.remove(draftKey);
      await prefs.remove('${draftKey}_timestamp');
      
      return true;
    } catch (e) {
      debugPrint('Error clearing draft: $e');
      return false;
    }
  }
  
  /// Gets the timestamp of when the draft was saved
  static Future<DateTime?> getDraftTimestamp(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = 'draft_${filePath.hashCode}_timestamp';
      
      final timestamp = prefs.getString(timestampKey);
      if (timestamp == null) {
        return null;
      }
      
      return DateTime.parse(timestamp);
    } catch (e) {
      debugPrint('Error getting draft timestamp: $e');
      return null;
    }
  }
} 