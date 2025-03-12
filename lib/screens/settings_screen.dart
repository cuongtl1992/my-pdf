import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Language settings
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(
              LanguageProvider.supportedLanguages[languageProvider.getCurrentLanguageCode()] ?? 'Unknown',
            ),
            leading: const Icon(Icons.language),
            onTap: () {
              _showLanguageSelectionDialog(context, languageProvider);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context, LanguageProvider languageProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, 'system', l10n.systemDefault, languageProvider),
                const Divider(),
                _buildLanguageOption(context, 'en', l10n.english, languageProvider),
                _buildLanguageOption(context, 'es', l10n.spanish, languageProvider),
                _buildLanguageOption(context, 'fr', l10n.french, languageProvider),
                _buildLanguageOption(context, 'de', l10n.german, languageProvider),
                _buildLanguageOption(context, 'zh', l10n.chinese, languageProvider),
                _buildLanguageOption(context, 'vi', l10n.vietnamese, languageProvider),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    String languageCode, 
    String languageName, 
    LanguageProvider languageProvider
  ) {
    final isSelected = languageProvider.getCurrentLanguageCode() == languageCode;
    
    return ListTile(
      title: Text(languageName),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () async {
        await languageProvider.setLanguage(languageCode);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.languageChanged),
            ),
          );
        }
      },
    );
  }
} 