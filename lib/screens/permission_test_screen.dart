import 'package:flutter/material.dart';
import '../utils/permission_test.dart';
import '../utils/file_service.dart';

class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  Map<String, dynamic> _permissionStatus = {};
  String? _selectedFilePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final status = await PermissionTest.checkPermissions();
    
    setState(() {
      _permissionStatus = status;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final results = await PermissionTest.requestPermissions();
    
    setState(() {
      _permissionStatus = results;
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    final filePath = await FileService.pickPdfFile();
    
    setState(() {
      _selectedFilePath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Test'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permission Status:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _permissionStatus.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text('Request Permissions'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Pick PDF File'),
                  ),
                  if (_selectedFilePath != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Selected File:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_selectedFilePath!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
} 