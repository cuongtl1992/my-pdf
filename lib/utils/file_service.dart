import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:device_info_plus/device_info_plus.dart';

class FileService {
  // Pick a PDF file from storage
  static Future<String?> pickPdfFile() async {
    try {
      // Request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        debugPrint('Storage permission denied');
        return null;
      }

      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // Return the file path if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return file.path;
      }
    } catch (e) {
      debugPrint('Error picking PDF file: $e');
    }
    return null;
  }

  // Request storage permission
  static Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android, we need to request storage permission
        // Check Android version
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt >= 30) {
          // Android 11 (API level 30) and above
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          }
          final status = await Permission.manageExternalStorage.request();
          return status.isGranted;
        } else {
          // Android 10 and below
          if (await Permission.storage.isGranted) {
            return true;
          }
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } else {
        // For iOS and other platforms
        if (await Permission.storage.isGranted) {
          return true;
        }
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  // Check if a file exists
  static bool fileExists(String filePath) {
    try {
      return File(filePath).existsSync();
    } catch (e) {
      debugPrint('Error checking if file exists: $e');
      return false;
    }
  }

  // Get file size in a readable format
  static String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 'Unknown size';
    }
  }
  
  // Share a file
  static Future<void> shareFile(String filePath) async {
    try {
      if (!fileExists(filePath)) {
        debugPrint('File does not exist: $filePath');
        return;
      }
      
      final file = File(filePath);
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sharing PDF file',
        text: 'Check out this PDF file',
      );
      
      debugPrint('Share result: ${result.status}');
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }
  
  // Open the folder containing a file
  static Future<bool> openFileLocation(String filePath) async {
    try {
      if (!fileExists(filePath)) {
        debugPrint('File does not exist: $filePath');
        return false;
      }
      
      final directory = path.dirname(filePath);
      
      if (Platform.isAndroid) {
        // On Android, we can't directly open a folder, but we can show the file in a file manager
        return await _openAndroidFileManager(filePath);
      } else if (Platform.isIOS) {
        // On iOS, we can't directly open a folder in the Files app
        // Instead, we'll share the file which gives the option to save it elsewhere
        await shareFile(filePath);
        return true;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // On desktop platforms, we can open the folder directly
        final uri = Uri.file(directory);
        return await url_launcher.launchUrl(uri);
      }
      
      return false;
    } catch (e) {
      debugPrint('Error opening file location: $e');
      return false;
    }
  }
  
  // Helper method to open Android file manager
  static Future<bool> _openAndroidFileManager(String filePath) async {
    try {
      // On Android, we can use the ACTION_VIEW intent with a content URI
      // This will open the file in the default file manager
      final uri = Uri.file(filePath);
      return await url_launcher.launchUrl(uri);
    } catch (e) {
      debugPrint('Error opening Android file manager: $e');
      return false;
    }
  }
} 