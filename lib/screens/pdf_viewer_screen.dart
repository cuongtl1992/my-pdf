import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/pdf_provider.dart';
import '../widgets/pdf_editing_toolbar.dart';
import '../utils/error_handler.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // Add a field to store the provider reference
  late PdfProvider _pdfProvider;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Store a reference to the provider
    _pdfProvider = Provider.of<PdfProvider>(context, listen: false);
    
    // Only run initialization logic once
    if (!_initialized) {
      _initialized = true;
      
      // Load sample PDF if no file is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pdfProvider.currentFilePath == null) {
          _pdfProvider.setAssetPdf('assets/samples/sample.pdf');
        } else {
          // Check for draft
          _checkForDraft(_pdfProvider);
        }
      });
    }
  }
  
  // Check if there's a draft for the current file
  Future<void> _checkForDraft(PdfProvider pdfProvider) async {
    if (pdfProvider.hasDraft && pdfProvider.currentFilePath != null) {
      final timestamp = pdfProvider.draftTimestamp;
      final formattedTime = timestamp != null 
          ? DateFormat.yMd().add_jm().format(timestamp)
          : 'unknown time';
      
      // Show dialog to ask if user wants to resume editing
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(l10n.unsavedChanges),
            content: Text(l10n.resumeUnsavedSession(formattedTime, timestamp ?? DateTime.now())),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  pdfProvider.clearDraft();
                },
                child: Text(l10n.discard),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  pdfProvider.loadDraft();
                },
                child: Text(l10n.resume),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pdfViewer),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
              if (pdfProvider.currentFilePath != null && !pdfProvider.isAssetPdf) {
                pdfProvider.shareCurrentFile();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cannotShareSamplePdf),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
              if (pdfProvider.currentFilePath != null && !pdfProvider.isAssetPdf) {
                pdfProvider.openCurrentFileLocation();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cannotOpenFolderForSamplePdf),
                  ),
                );
              }
            },
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

          if (pdfProvider.currentFilePath == null) {
            return Center(
              child: Text(l10n.noPdfSelected),
            );
          }
          
          // Handle password-protected PDFs
          if (pdfProvider.isPasswordProtected) {
            return _buildPasswordPrompt(context, pdfProvider);
          }
          
          // Handle corrupt PDFs
          if (pdfProvider.isCorrupt) {
            return _buildCorruptPdfMessage(context);
          }
          
          // Show warning for large files
          if (pdfProvider.isLargeFile && !pdfProvider.isAssetPdf) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLargeFileWarning(context);
            });
          }

          // Build the PDF viewer based on whether it's an asset or a file
          return Stack(
            children: [
              // PDF Viewer
              _buildPdfViewer(pdfProvider),
              
              // Page indicator
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.page(
                        pdfProvider.currentPage + 1,
                        pdfProvider.pdfViewerController?.pageCount ?? 1,
                        pdfProvider.currentPage + 1
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              
              // Scroll throttling warning
              if (pdfProvider.isScrollThrottled)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.scrollingTooFast,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Editing toolbar
              const PdfEditingToolbar(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
          pdfProvider.toggleEditingMode();
          
          if (pdfProvider.isEditing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.editingModeEnabled),
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.editingModeDisabled),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: Consumer<PdfProvider>(
          builder: (context, pdfProvider, child) {
            return Icon(
              pdfProvider.isEditing ? Icons.edit_off : Icons.edit,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.text_format),
                tooltip: AppLocalizations.of(context)!.addAnnotation,
                onPressed: () {
                  final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
                  if (!pdfProvider.isEditing) {
                    pdfProvider.toggleEditingMode();
                  }
                  pdfProvider.toggleAnnotationMode();
                  if (pdfProvider.isAnnotating) {
                    // Show annotation dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        final textController = TextEditingController();
                        return AlertDialog(
                          title: Text(l10n.addAnnotation),
                          content: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: l10n.enterAnnotationText,
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                pdfProvider.toggleAnnotationMode();
                              },
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (textController.text.isNotEmpty) {
                                  // Get the center of the screen as the position
                                  final size = MediaQuery.of(context).size;
                                  final position = Offset(size.width / 2, size.height / 3);
                                  
                                  pdfProvider.addAnnotation(textController.text, position);
                                  Navigator.of(context).pop();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.annotationAdded),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.add),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.highlight),
                tooltip: AppLocalizations.of(context)!.highlightText,
                onPressed: () {
                  final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
                  if (!pdfProvider.isEditing) {
                    pdfProvider.toggleEditingMode();
                  }
                  pdfProvider.toggleHighlightingMode();
                  
                  if (pdfProvider.isHighlighting) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.selectTextToHighlight),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: AppLocalizations.of(context)!.deletePage,
                onPressed: () {
                  final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
                  final l10n = AppLocalizations.of(context)!;
                  
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deletePage),
                      content: Text(l10n.deletePageConfirmation(pdfProvider.currentPage + 1)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            pdfProvider.deletePage();
                            Navigator.of(context).pop();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.pageDeleted),
                                action: SnackBarAction(
                                  label: l10n.undoPageDeletion,
                                  onPressed: () {
                                    pdfProvider.undoLastOperation();
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: AppLocalizations.of(context)!.savePdf,
                onPressed: () {
                  final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
                  final l10n = AppLocalizations.of(context)!;
                  
                  if (pdfProvider.isAssetPdf) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.cannotShareSamplePdf),
                      ),
                    );
                    return;
                  }
                  
                  if (!pdfProvider.hasUnsavedChanges) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.noChangesToSave),
                      ),
                    );
                    return;
                  }
                  
                  // Show save dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      final textController = TextEditingController();
                      final originalFileName = path.basenameWithoutExtension(pdfProvider.currentFilePath!);
                      textController.text = '${originalFileName}_edited';
                      
                      return AlertDialog(
                        title: Text(l10n.savePdf),
                        content: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: l10n.enterFileName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              
                              final fileName = textController.text.trim();
                              final success = await pdfProvider.saveEditedPdf(
                                fileName.isNotEmpty ? fileName : null
                              );
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? l10n.pdfSaved : l10n.errorSavingPdf),
                                  ),
                                );
                              }
                            },
                            child: Text(l10n.save),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer(PdfProvider pdfProvider) {
    // Apply scroll throttling
    final onPageChanged = (PdfPageChangedDetails details) {
      if (!pdfProvider.shouldThrottleScroll()) {
        pdfProvider.setCurrentPage(details.newPageNumber - 1);
      }
    };
    
    if (pdfProvider.isAssetPdf) {
      // Asset PDF
      return SfPdfViewer.asset(
        pdfProvider.currentFilePath!,
        controller: pdfProvider.pdfViewerController,
        onPageChanged: onPageChanged,
      );
    } else {
      // File PDF
      return SfPdfViewer.file(
        File(pdfProvider.currentFilePath!),
        controller: pdfProvider.pdfViewerController,
        onPageChanged: onPageChanged,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('PDF load failed: ${details.error}, ${details.description}');
          // This will be handled by the isCorrupt check
        },
      );
    }
  }
  
  // Widget for password prompt
  Widget _buildPasswordPrompt(BuildContext context, PdfProvider pdfProvider) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.passwordProtectedPdf,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.enterPasswordToOpen,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.password),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          final success = await pdfProvider.setPassword(textController.text);
                          
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.incorrectPassword),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(l10n.unlock),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget for corrupt PDF message
  Widget _buildCorruptPdfMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.corruptPdf,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.corruptPdfMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.goBack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Show warning for large files
  void _showLargeFileWarning(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.largeFile),
        content: Text(l10n.largeFileWarning),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.continue_),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Check if there are unsaved changes using the stored provider reference
    if (_pdfProvider.hasUnsavedChanges && _pdfProvider.currentFilePath != null && !_pdfProvider.isAssetPdf) {
      // The draft will be auto-saved by the provider internally
      debugPrint('Unsaved changes detected on dispose');
    }
    super.dispose();
  }
} 