# MyPdf - Flutter PDF Viewer & Editor

A cross-platform (Android & iOS) PDF Viewer & Editor built with Flutter. This app allows users to open, view, annotate, highlight, delete pages, and save PDFs efficiently.

## Features

- **PDF Viewing**: Open PDF files from local storage with smooth scrolling & pinch-to-zoom
- **PDF Editing**: Add annotations, highlight text, delete pages
- **File Management**: Recent files list, search & filter
- **File Sharing**: Share PDFs via various apps
- **Security & Error Handling**: Support for password-protected PDFs, corrupt PDF handling
- **Localization**: Support for multiple languages (English, Spanish, French, German, Chinese, Vietnamese)

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / Xcode for mobile deployment

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/my-pdf.git
   cd my-pdf
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   ├── recent_file.dart       # Recent file model
│   ├── pdf_edit_operation.dart # PDF edit operation model
│   └── pdf_draft.dart         # PDF draft model
├── providers/          # State management
│   ├── pdf_provider.dart      # PDF state management
│   └── language_provider.dart # Localization state management
├── screens/            # App screens
│   ├── home_screen.dart       # Home screen
│   ├── pdf_viewer_screen.dart # PDF viewer screen
│   └── settings_screen.dart   # Settings screen
├── utils/              # Utility functions
│   ├── file_service.dart      # File operations
│   ├── pdf_editor_service.dart # PDF editing operations
│   └── error_handler.dart     # Error handling
├── widgets/            # Reusable widgets
│   ├── pdf_editing_toolbar.dart # PDF editing toolbar
│   └── recent_file_item.dart  # Recent file list item
└── l10n/               # Localization
```

## Dependencies

- **PDF Rendering & Editing**:
  - `syncfusion_flutter_pdfviewer`: For displaying PDFs
  - `syncfusion_flutter_pdf`: For modifying PDFs
- **State Management**: Provider
- **Storage Access**: `path_provider` and `permission_handler`
- **Other**: `shared_preferences` for storing app settings

## Testing

The app includes comprehensive testing:

- **Unit Tests**: Test individual components
- **Widget Tests**: Test UI components
- **Integration Tests**: Test end-to-end workflows

Run the tests with:
```
# Run unit and widget tests
flutter test

# Run integration tests
flutter test integration_test
```

See the [Testing Guide](test/README.md) for more details.

## User Workflow

1. **Home Screen**: 
   - View recent files
   - Open a PDF file
   - Search for files
   - Sort files by date

2. **PDF Viewer Screen**:
   - View PDF content
   - Navigate between pages
   - Enter editing mode
   - Share PDF

3. **PDF Editing**:
   - Add annotations
   - Highlight text
   - Delete pages
   - Undo operations
   - Save edited PDF

4. **Error Handling**:
   - Password-protected PDFs
   - Corrupt PDFs
   - Large PDFs
   - Unsaved changes

## CI/CD Setup

This project uses GitHub Actions for CI/CD. The workflow includes:

1. **Lint & Format Check**: Ensures code quality
2. **Unit & Widget Tests**: Verifies functionality
3. **Integration Tests**: Verifies end-to-end workflows
4. **Build**: Creates debug APK for Android and iOS

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Syncfusion](https://www.syncfusion.com/) for their excellent PDF libraries
- Flutter team for the amazing framework
