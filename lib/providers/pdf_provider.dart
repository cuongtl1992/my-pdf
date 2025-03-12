import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as path;
import '../models/recent_file.dart';
import '../models/pdf_edit_operation.dart';
import '../models/pdf_draft.dart';
import '../utils/file_service.dart';
import '../utils/pdf_editor_service.dart';
import '../utils/error_handler.dart';

class PdfProvider extends ChangeNotifier {
  List<RecentFile> _recentFiles = [];
  List<RecentFile> _filteredRecentFiles = [];
  String? _currentFilePath;
  int _currentPage = 0;
  bool _isLoading = false;
  PdfViewerController? _pdfViewerController;
  bool _isAssetPdf = false;
  String _searchQuery = '';
  
  // Editing state
  List<PdfEditOperation> _editOperations = [];
  PdfEditOperation? _lastUndoneOperation;
  bool _isEditing = false;
  bool _isAnnotating = false;
  bool _isHighlighting = false;
  bool _hasUnsavedChanges = false;
  
  // Error handling state
  bool _isPasswordProtected = false;
  bool _isCorrupt = false;
  bool _isLargeFile = false;
  String? _password;
  bool _hasDraft = false;
  DateTime? _draftTimestamp;
  
  // Scroll throttling
  DateTime _lastScrollTime = DateTime.now();
  bool _isScrollThrottled = false;

  // Getters
  List<RecentFile> get recentFiles => _filteredRecentFiles.isEmpty && _searchQuery.isEmpty 
      ? _recentFiles 
      : _filteredRecentFiles;
  String? get currentFilePath => _currentFilePath;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  PdfViewerController? get pdfViewerController => _pdfViewerController;
  bool get isAssetPdf => _isAssetPdf;
  String get searchQuery => _searchQuery;
  
  // Editing getters
  bool get isEditing => _isEditing;
  bool get isAnnotating => _isAnnotating;
  bool get isHighlighting => _isHighlighting;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get canUndo => _editOperations.isNotEmpty;
  
  // Error handling getters
  bool get isPasswordProtected => _isPasswordProtected;
  bool get isCorrupt => _isCorrupt;
  bool get isLargeFile => _isLargeFile;
  bool get hasDraft => _hasDraft;
  DateTime? get draftTimestamp => _draftTimestamp;
  bool get isScrollThrottled => _isScrollThrottled;

  // Initialize the provider
  Future<void> initialize() async {
    _pdfViewerController = PdfViewerController();
    await _loadRecentFiles();
    await _loadLastViewedPage();
  }

  // Load recent files from SharedPreferences
  Future<void> _loadRecentFiles() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentFilesJson = prefs.getStringList('recentFiles') ?? [];
      
      _recentFiles = recentFilesJson
          .map((json) => RecentFile.fromJson(jsonDecode(json)))
          .where((file) => FileService.fileExists(file.path))
          .toList();
      
      // Sort by last accessed time (most recent first)
      _recentFiles.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
      
      await _saveRecentFiles();
    } catch (e) {
      // Handle errors gracefully, especially in tests
      debugPrint('Error loading recent files: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save recent files to SharedPreferences
  Future<void> _saveRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentFilesJson = _recentFiles
          .map((file) => jsonEncode(file.toJson()))
          .toList();
      
      await prefs.setStringList('recentFiles', recentFilesJson);
    } catch (e) {
      // Handle errors gracefully, especially in tests
      debugPrint('Error saving recent files: $e');
    }
  }

  // Add a file to recent files
  Future<void> addToRecentFiles(String filePath) async {
    // Create a new RecentFile object
    final newFile = RecentFile(
      path: filePath,
      lastAccessed: DateTime.now(),
    );
    
    // Remove if already exists
    _recentFiles.removeWhere((file) => file.path == filePath);
    
    // Add to the beginning of the list
    _recentFiles.insert(0, newFile);
    
    // Keep only the 10 most recent files
    if (_recentFiles.length > 10) {
      _recentFiles = _recentFiles.sublist(0, 10);
    }
    
    await _saveRecentFiles();
    
    // Update filtered list if search is active
    if (_searchQuery.isNotEmpty) {
      _filterRecentFiles(_searchQuery);
    }
    
    notifyListeners();
  }

  // Remove a file from recent files
  Future<void> removeFromRecentFiles(String filePath) async {
    _recentFiles.removeWhere((file) => file.path == filePath);
    
    // Update filtered list if search is active
    if (_searchQuery.isNotEmpty) {
      _filterRecentFiles(_searchQuery);
    }
    
    await _saveRecentFiles();
    notifyListeners();
  }

  // Search/filter recent files by name
  void searchRecentFiles(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredRecentFiles = [];
    } else {
      _filterRecentFiles(query);
    }
    
    notifyListeners();
  }

  // Filter recent files based on search query
  void _filterRecentFiles(String query) {
    _filteredRecentFiles = _recentFiles
        .where((file) => 
            File(file.path).existsSync() && 
            path.basename(file.path).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Sort recent files by last accessed time
  void sortRecentFilesByDate({bool ascending = false}) {
    if (ascending) {
      _recentFiles.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));
    } else {
      _recentFiles.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    }
    
    // Update filtered list if search is active
    if (_searchQuery.isNotEmpty) {
      _filterRecentFiles(_searchQuery);
    }
    
    notifyListeners();
  }

  // Pick a PDF file using file picker
  Future<String?> pickPdfFile() async {
    final filePath = await FileService.pickPdfFile();
    
    if (filePath != null) {
      final result = await setCurrentFile(filePath);
      if (result) {
        return filePath;
      }
    }
    
    return null;
  }

  // Set current file with error handling
  Future<bool> setCurrentFile(String filePath) async {
    _setLoading(true);
    
    try {
      // Reset error states
      _isPasswordProtected = false;
      _isCorrupt = false;
      _isLargeFile = false;
      _password = null;
      
      // Check for errors
      _isCorrupt = await PdfErrorHandler.isCorrupt(filePath);
      if (_isCorrupt) {
        debugPrint('PDF file is corrupt: $filePath');
        _setLoading(false);
        notifyListeners();
        return false;
      }
      
      _isPasswordProtected = await PdfErrorHandler.isPasswordProtected(filePath);
      if (_isPasswordProtected && _password == null) {
        debugPrint('PDF file is password-protected: $filePath');
        _setLoading(false);
        notifyListeners();
        return false;
      }
      
      _isLargeFile = await PdfErrorHandler.isLargeFile(filePath);
      if (_isLargeFile) {
        debugPrint('PDF file is large (>50MB): $filePath');
        // We'll still load it, but the UI will show a warning
      }
      
      // Check for draft
      _hasDraft = await PdfErrorHandler.hasDraft(filePath);
      if (_hasDraft) {
        _draftTimestamp = await PdfErrorHandler.getDraftTimestamp(filePath);
        debugPrint('Found draft for PDF file: $filePath');
      }
      
      _currentFilePath = filePath;
      _isAssetPdf = false;
      await _loadLastViewedPage();
      await addToRecentFiles(filePath);
      
      // Reset editing state
      _resetEditingState();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting current file: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set password for password-protected PDF
  Future<bool> setPassword(String password) async {
    if (_currentFilePath == null || !_isPasswordProtected) return false;
    
    _password = password;
    
    // TODO: Implement actual password verification with Syncfusion PDF library
    // For now, we'll just assume the password is correct
    
    notifyListeners();
    return true;
  }

  // Set current asset PDF
  void setAssetPdf(String assetPath) {
    _currentFilePath = assetPath;
    _isAssetPdf = true;
    _loadLastViewedPage();
    
    // Reset editing state
    _resetEditingState();
    
    // Reset error states
    _isPasswordProtected = false;
    _isCorrupt = false;
    _isLargeFile = false;
    _password = null;
    _hasDraft = false;
    _draftTimestamp = null;
    
    notifyListeners();
  }

  // Set current page
  void setCurrentPage(int page) {
    _currentPage = page;
    saveLastViewedPage();
    notifyListeners();
  }

  // Navigate to next page
  void nextPage() {
    if (_pdfViewerController != null) {
      _pdfViewerController!.nextPage();
      _currentPage = _pdfViewerController!.pageNumber - 1;
      saveLastViewedPage();
      notifyListeners();
    }
  }

  // Navigate to previous page
  void previousPage() {
    if (_pdfViewerController != null) {
      _pdfViewerController!.previousPage();
      _currentPage = _pdfViewerController!.pageNumber - 1;
      saveLastViewedPage();
      notifyListeners();
    }
  }

  // Jump to specific page
  void goToPage(int page) {
    if (_pdfViewerController != null) {
      _pdfViewerController!.jumpToPage(page + 1); // +1 because controller uses 1-based indexing
      _currentPage = page;
      saveLastViewedPage();
      notifyListeners();
    }
  }

  // Save last viewed page to SharedPreferences
  Future<void> saveLastViewedPage() async {
    if (_currentFilePath != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastPage_${_currentFilePath!.hashCode}', _currentPage);
      } catch (e) {
        // Handle errors gracefully, especially in tests
        debugPrint('Error saving last viewed page: $e');
      }
    }
  }

  // Load last viewed page from SharedPreferences
  Future<void> _loadLastViewedPage() async {
    if (_currentFilePath != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        _currentPage = prefs.getInt('lastPage_${_currentFilePath!.hashCode}') ?? 0;
        notifyListeners();
      } catch (e) {
        // Handle errors gracefully, especially in tests
        debugPrint('Error loading last viewed page: $e');
      }
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Reset editing state
  void _resetEditingState() {
    _editOperations = [];
    _lastUndoneOperation = null;
    _isEditing = false;
    _isAnnotating = false;
    _isHighlighting = false;
    _hasUnsavedChanges = false;
  }
  
  // Toggle editing mode
  void toggleEditingMode() {
    _isEditing = !_isEditing;
    
    // If turning off editing, also turn off specific editing modes
    if (!_isEditing) {
      _isAnnotating = false;
      _isHighlighting = false;
    }
    
    notifyListeners();
  }
  
  // Toggle annotation mode
  void toggleAnnotationMode() {
    _isAnnotating = !_isAnnotating;
    
    // If turning on annotation mode, ensure editing mode is on and highlighting is off
    if (_isAnnotating) {
      _isEditing = true;
      _isHighlighting = false;
    }
    
    notifyListeners();
  }
  
  // Toggle highlighting mode
  void toggleHighlightingMode() {
    _isHighlighting = !_isHighlighting;
    
    // If turning on highlighting mode, ensure editing mode is on and annotation is off
    if (_isHighlighting) {
      _isEditing = true;
      _isAnnotating = false;
    }
    
    notifyListeners();
  }
  
  // Add annotation to the current page
  Future<void> addAnnotation(String text, Offset position, {Color color = Colors.blue}) async {
    if (_currentFilePath == null || _isAssetPdf) return;
    
    _setLoading(true);
    
    try {
      final operation = AnnotationOperation(
        pageIndex: _currentPage,
        text: text,
        position: position,
        color: color,
      );
      
      // Add to operations list for undo
      _editOperations.add(operation);
      _lastUndoneOperation = null;
      _hasUnsavedChanges = true;
      
      // Auto-save draft
      await _saveDraft();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding annotation: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add highlight to the current page
  Future<void> addHighlight(Rect? bounds, {Color color = Colors.yellow, double opacity = 0.5}) async {
    if (_currentFilePath == null || _isAssetPdf || bounds == null) return;
    
    _setLoading(true);
    
    try {
      final operation = HighlightOperation(
        pageIndex: _currentPage,
        bounds: bounds,
        color: color,
        opacity: opacity,
      );
      
      // Add to operations list for undo
      _editOperations.add(operation);
      _lastUndoneOperation = null;
      _hasUnsavedChanges = true;
      
      // Auto-save draft
      await _saveDraft();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding highlight: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete the current page
  Future<void> deletePage() async {
    if (_currentFilePath == null || _isAssetPdf) return;
    
    _setLoading(true);
    
    try {
      final operation = DeletePageOperation(
        pageIndex: _currentPage,
      );
      
      // Add to operations list for undo
      _editOperations.add(operation);
      _lastUndoneOperation = null;
      _hasUnsavedChanges = true;
      
      // Auto-save draft
      await _saveDraft();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting page: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Undo the last operation
  void undoLastOperation() {
    if (_editOperations.isEmpty) return;
    
    _lastUndoneOperation = _editOperations.removeLast();
    _hasUnsavedChanges = _editOperations.isNotEmpty;
    
    // Auto-save draft
    _saveDraft();
    
    notifyListeners();
  }
  
  // Save the edited PDF
  Future<bool> saveEditedPdf([String? customFilename]) async {
    if (_currentFilePath == null || _isAssetPdf || !_hasUnsavedChanges) return false;
    
    _setLoading(true);
    
    try {
      String? newPath;
      
      if (customFilename != null && customFilename.isNotEmpty) {
        final file = await PdfEditorService.saveEditedPdfWithCustomName(
          _currentFilePath!,
          _editOperations,
          customFilename,
        );
        newPath = file.path;
      } else {
        String currentPath = _currentFilePath!;
        
        // Apply each operation in sequence
        for (final operation in _editOperations) {
          if (operation is AnnotationOperation) {
            final file = await PdfEditorService.addAnnotation(currentPath, operation);
            currentPath = file.path;
          } else if (operation is HighlightOperation) {
            final file = await PdfEditorService.addHighlight(currentPath, operation);
            currentPath = file.path;
          } else if (operation is DeletePageOperation) {
            final file = await PdfEditorService.deletePage(currentPath, operation);
            currentPath = file.path;
          }
        }
        
        newPath = currentPath;
      }
      
      // Clear draft
      if (newPath != null) {
        await PdfErrorHandler.clearDraft(_currentFilePath!);
        _hasDraft = false;
        _draftTimestamp = null;
      }
      
      // Reset editing state
      _resetEditingState();
      
      // Set the new file as current
      if (newPath != null) {
        await setCurrentFile(newPath);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error saving edited PDF: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Save draft of current editing state
  Future<bool> _saveDraft() async {
    if (_currentFilePath == null || _isAssetPdf || !_hasUnsavedChanges) return false;
    
    try {
      final draft = PdfDraft(
        filePath: _currentFilePath!,
        operations: List.from(_editOperations),
        currentPage: _currentPage,
        timestamp: DateTime.now(),
      );
      
      final success = await PdfErrorHandler.saveDraft(
        _currentFilePath!,
        draft.toJson(),
      );
      
      if (success) {
        _hasDraft = true;
        _draftTimestamp = draft.timestamp;
      }
      
      return success;
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return false;
    }
  }
  
  // Load draft for current file
  Future<bool> loadDraft() async {
    if (_currentFilePath == null || _isAssetPdf || !_hasDraft) return false;
    
    _setLoading(true);
    
    try {
      final draftData = await PdfErrorHandler.getDraft(_currentFilePath!);
      if (draftData == null) return false;
      
      final draft = PdfDraft.fromJson(draftData);
      if (draft == null) return false;
      
      // Restore state from draft
      _editOperations = draft.operations;
      _currentPage = draft.currentPage;
      _hasUnsavedChanges = _editOperations.isNotEmpty;
      
      // Go to the saved page
      goToPage(_currentPage);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Clear draft for current file
  Future<bool> clearDraft() async {
    if (_currentFilePath == null) return false;
    
    try {
      final success = await PdfErrorHandler.clearDraft(_currentFilePath!);
      
      if (success) {
        _hasDraft = false;
        _draftTimestamp = null;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error clearing draft: $e');
      return false;
    }
  }
  
  // Handle scroll throttling to prevent lag/crashes
  bool shouldThrottleScroll() {
    final now = DateTime.now();
    final timeSinceLastScroll = now.difference(_lastScrollTime);
    
    if (timeSinceLastScroll.inMilliseconds < 100) {
      // If less than 100ms since last scroll, throttle
      _isScrollThrottled = true;
      notifyListeners();
      
      // Reset throttle after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrollThrottled = false;
        notifyListeners();
      });
      
      return true;
    }
    
    _lastScrollTime = now;
    return false;
  }
  
  // Share the current PDF file
  Future<void> shareCurrentFile() async {
    if (_currentFilePath == null || _isAssetPdf) return;
    
    try {
      await FileService.shareFile(_currentFilePath!);
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }
  
  // Open the folder containing the current PDF file
  Future<bool> openCurrentFileLocation() async {
    if (_currentFilePath == null || _isAssetPdf) return false;
    
    try {
      return await FileService.openFileLocation(_currentFilePath!);
    } catch (e) {
      debugPrint('Error opening file location: $e');
      return false;
    }
  }

  // Clear search query
  void clearSearch() {
    _searchQuery = '';
    _filteredRecentFiles = [];
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _pdfViewerController?.dispose();
    super.dispose();
  }

  // Simulate a password-protected PDF for testing purposes
  void simulatePasswordProtectedPdf() {
    _isPasswordProtected = true;
    _password = 'password';
    notifyListeners();
  }

  // Simulate a corrupt PDF for testing purposes
  void simulateCorruptPdf() {
    _isCorrupt = true;
    notifyListeners();
  }

  // Simulate a large PDF for testing purposes
  void simulateLargePdf() {
    _isLargeFile = true;
    notifyListeners();
  }

  // Set the draft flag for testing purposes
  void setHasDraft(bool value) {
    _hasDraft = value;
    notifyListeners();
  }

  // Set the draft timestamp for testing purposes
  void setDraftTimestamp(DateTime timestamp) {
    _draftTimestamp = timestamp;
    notifyListeners();
  }
} 