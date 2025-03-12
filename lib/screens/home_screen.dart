import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/pdf_provider.dart';
import '../widgets/recent_file_item.dart';
import 'pdf_viewer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize the PDF provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PdfProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPdfViewer(BuildContext context, [String? filePath]) {
    if (filePath != null) {
      Provider.of<PdfProvider>(context, listen: false).setCurrentFile(filePath);
    } else {
      // If no file path is provided, use the file picker
      _pickAndOpenPdf(context);
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/pdf_viewer'),
        builder: (context) => const PdfViewerScreen(),
      ),
    );
  }

  Future<void> _pickAndOpenPdf(BuildContext context) async {
    final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
    final filePath = await pdfProvider.pickPdfFile();
    
    if (filePath != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/pdf_viewer'),
          builder: (context) => const PdfViewerScreen(),
        ),
      );
    }
  }

  void _refreshRecentFiles() {
    Provider.of<PdfProvider>(context, listen: false).initialize();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.recentFilesRefreshed),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        Provider.of<PdfProvider>(context, listen: false).clearSearch();
      }
    });
  }

  void _performSearch(String query) {
    Provider.of<PdfProvider>(context, listen: false).searchRecentFiles(query);
  }

  void _sortRecentFiles() {
    final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.mostRecentFirst),
                onTap: () {
                  pdfProvider.sortRecentFilesByDate(ascending: false);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time_filled),
                title: Text(l10n.oldestFirst),
                onTap: () {
                  pdfProvider.sortRecentFilesByDate(ascending: true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchPdfFiles,
                  border: InputBorder.none,
                ),
                onChanged: _performSearch,
              )
            : Text(l10n.appTitle),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Consumer<PdfProvider>(
        builder: (context, pdfProvider, child) {
          if (pdfProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Large centered "Open File" button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPdfViewer(context),
                    icon: const Icon(Icons.file_open, size: 36),
                    label: Text(
                      l10n.openPdfFile,
                      style: const TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Recent Files Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recentFiles,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: _sortRecentFiles,
                      icon: const Icon(Icons.sort),
                      label: Text(l10n.sort),
                    ),
                  ],
                ),
              ),
              
              // Recent Files List
              Expanded(
                child: pdfProvider.recentFiles.isEmpty
                    ? _buildEmptyRecentFiles(l10n)
                    : _buildRecentFilesList(pdfProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshRecentFiles,
        tooltip: AppLocalizations.of(context)!.refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyRecentFiles(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecentFiles,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recentFilesWillAppearHere,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFilesList(PdfProvider pdfProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pdfProvider.recentFiles.length,
      itemBuilder: (context, index) {
        final recentFile = pdfProvider.recentFiles[index];
        final filePath = recentFile.path;
        final file = File(filePath);
        
        // Check if file exists
        if (!file.existsSync()) {
          return const SizedBox.shrink(); // Skip if file doesn't exist
        }
        
        return RecentFileItem(
          filePath: filePath,
          fileName: path.basename(filePath),
          lastAccessed: recentFile.lastAccessed,
          onTap: () => _navigateToPdfViewer(context, filePath),
          onDelete: () => pdfProvider.removeFromRecentFiles(filePath),
        );
      },
    );
  }
} 