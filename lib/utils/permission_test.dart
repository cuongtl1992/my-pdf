import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionTest {
  static Future<Map<String, dynamic>> checkPermissions() async {
    final Map<String, dynamic> permissionStatus = {};
    
    try {
      // Check storage permission
      permissionStatus['storage'] = await Permission.storage.status.isGranted;
      
      // Check if we're on Android and get the SDK version
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        permissionStatus['androidSdkVersion'] = sdkInt;
        
        // Check manage external storage permission for Android 11+
        if (sdkInt >= 30) {
          permissionStatus['manageExternalStorage'] = 
              await Permission.manageExternalStorage.status.isGranted;
        }
      }
      
      return permissionStatus;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      permissionStatus['error'] = e.toString();
      return permissionStatus;
    }
  }
  
  static Future<Map<String, dynamic>> requestPermissions() async {
    final Map<String, dynamic> permissionResults = {};
    
    try {
      // For Android, check the SDK version
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        permissionResults['androidSdkVersion'] = sdkInt;
        
        // For Android 11+ (API level 30+)
        if (sdkInt >= 30) {
          final status = await Permission.manageExternalStorage.request();
          permissionResults['manageExternalStorage'] = status.isGranted;
        } else {
          // For Android 10 and below
          final status = await Permission.storage.request();
          permissionResults['storage'] = status.isGranted;
        }
      } else {
        // For iOS and other platforms
        final status = await Permission.storage.request();
        permissionResults['storage'] = status.isGranted;
      }
      
      return permissionResults;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      permissionResults['error'] = e.toString();
      return permissionResults;
    }
  }
} 