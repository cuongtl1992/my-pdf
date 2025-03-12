import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/pdf_provider.dart';
import 'package:path/path.dart' as path;

class PdfEditingToolbar extends StatelessWidget {
  const PdfEditingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<PdfProvider>(
      builder: (context, pdfProvider, child) {
        // Don't show the toolbar if not in editing mode
        if (!pdfProvider.isEditing) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 80,
          right: 16,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Annotation button
                  IconButton(
                    icon: Icon(
                      Icons.text_format,
                      color: pdfProvider.isAnnotating
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    tooltip: l10n.addAnnotation,
                    onPressed: () {
                      pdfProvider.toggleAnnotationMode();
                      if (pdfProvider.isAnnotating) {
                        _showAnnotationDialog(context, pdfProvider);
                      }
                    },
                  ),
                  
                  // Highlight button
                  IconButton(
                    icon: Icon(
                      Icons.highlight,
                      color: pdfProvider.isHighlighting
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    tooltip: l10n.highlightText,
                    onPressed: () {
                      pdfProvider.toggleHighlightingMode();
                      if (pdfProvider.isHighlighting) {
                        _showHighlightInstructions(context);
                      }
                    },
                  ),
                  
                  // Delete page button
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: l10n.deletePage,
                    onPressed: () {
                      _showDeleteConfirmation(context, pdfProvider);
                    },
                  ),
                  
                  // Undo button
                  IconButton(
                    icon: const Icon(Icons.undo),
                    tooltip: l10n.undoPageDeletion,
                    onPressed: pdfProvider.canUndo
                        ? () {
                            pdfProvider.undoLastOperation();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.undoPageDeletion),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                  ),
                  
                  // Save button
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: l10n.savePdf,
                    onPressed: pdfProvider.hasUnsavedChanges
                        ? () async {
                            _showSaveOptions(context, pdfProvider);
                          }
                        : null,
                  ),
                  
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share PDF',
                    onPressed: !pdfProvider.isAssetPdf && pdfProvider.currentFilePath != null
                        ? () {
                            pdfProvider.shareCurrentFile();
                          }
                        : null,
                  ),
                  
                  // Open folder button
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Open Containing Folder',
                    onPressed: !pdfProvider.isAssetPdf && pdfProvider.currentFilePath != null
                        ? () {
                            pdfProvider.openCurrentFileLocation();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show dialog to add annotation
  void _showAnnotationDialog(BuildContext context, PdfProvider pdfProvider) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              pdfProvider.toggleAnnotationMode(); // Turn off annotation mode
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
                pdfProvider.toggleAnnotationMode(); // Turn off annotation mode
                
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
      ),
    );
  }

  // Show instructions for highlighting
  void _showHighlightInstructions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.selectTextToHighlight),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show confirmation dialog for deleting a page
  void _showDeleteConfirmation(BuildContext context, PdfProvider pdfProvider) {
    final l10n = AppLocalizations.of(context)!;
    
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
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
  
  // Show save options dialog
  void _showSaveOptions(BuildContext context, PdfProvider pdfProvider) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController();
    final originalFileName = path.basenameWithoutExtension(pdfProvider.currentFilePath!);
    textController.text = '${originalFileName}_edited';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              if (fileName.isNotEmpty) {
                final success = await pdfProvider.saveEditedPdf(fileName);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? l10n.pdfSaved : l10n.errorSavingPdf),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
} 