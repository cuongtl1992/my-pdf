# Flutter PDF Viewer & Editor - ToDo Checklist

## 1. Project Setup & Initial Configuration
- [x] Create a new Flutter project.
- [x] Set up a Git repository.
- [x] Configure a basic CI/CD pipeline (if applicable).
- [x] Update `pubspec.yaml` to include:
  - [x] `syncfusion_flutter_pdfviewer`
  - [x] `syncfusion_flutter_pdf`
  - [x] Provider or Riverpod for state management
  - [x] `path_provider`
  - [x] `permission_handler`
  - [x] `shared_preferences`
  - [x] `flutter_localizations` (for multi-language support)
- [x] Create a basic `main.dart` with:
  - [x] A `MaterialApp`
  - [x] A placeholder HomeScreen that displays "Hello World".
- [x] Write a startup test to verify the app launches without errors.

## 2. Core UI & Navigation
- [x] Build Home Screen UI:
  - [x] A large centered "Open File" button.
  - [x] A list view for displaying up to 10 recent files (use placeholder data initially).
  - [x] A Floating Action Button (FAB) for quick access (e.g., refresh list).
- [x] Create a basic PDF Viewer Screen scaffold.
- [x] Implement navigation:
  - [x] Tapping "Open File" navigates from Home Screen to PDF Viewer Screen.
- [x] Write widget tests to verify:
  - [x] Home Screen renders correctly.
  - [x] Navigation from Home Screen to PDF Viewer Screen works.

## 3. PDF Viewing Functionality
- [x] Integrate `syncfusion_flutter_pdfviewer`:
  - [x] Load and display a sample local PDF asset.
  - [x] Enable smooth scrolling.
  - [x] Enable pinch-to-zoom and double-tap zoom functionality.
  - [x] Add navigation controls (previous/next buttons and a page indicator).
- [x] Implement local persistence to store the last viewed page (e.g., using Shared Preferences).
- [x] Write tests to ensure:
  - [x] The PDF is rendered correctly.
  - [x] Navigation controls function as expected.
  - [x] The last viewed page is saved and reloaded correctly.

## 4. File Management & Recent Files
- [x] Integrate file picker functionality to select a PDF from local storage.
- [x] Request and manage necessary permissions using `permission_handler`.
- [x] Implement a Recent Files list:
  - [x] Store up to 10 files.
  - [x] Sort files by last accessed time.
  - [x] Allow search/filter by file name.
  - [x] Support swipe-to-delete for recent file entries (without deleting the actual file).
- [x] Write tests to simulate:
  - [x] File selection.
  - [x] Adding/removing files from the Recent Files list.
  - [x] Persistence of the recent files list between app sessions.

## 5. PDF Editing (Annotations, Highlighting, Delete Page)
- [x] Integrate `syncfusion_flutter_pdf` for PDF editing features.
- [x] Implement editing functionalities:
  - [x] **Annotations:** Allow users to add text notes at any position.
  - [x] **Highlighting:** Enable text selection and highlighting (default yellow, 50% transparency).
  - [x] **Delete Page:** Provide a delete option for the current page with confirmation.
  - [x] **Undo Support:** Allow undoing the last editing action (annotation, highlight, or deletion) before saving.
- [x] Create a floating toolbar with icons for each editing function.
- [x] Write tests to verify:
  - [x] Annotations and highlights are rendered correctly.
  - [x] Page deletion works as intended.
  - [x] Undo functionality reverses the last action correctly.

## 6. Saving, Exporting & File Sharing
- [x] Implement saving functionality:
  - [x] Save edited PDFs in the same directory with a unique filename pattern (e.g., `document_edited(1).pdf`).
  - [x] Provide an option for renaming the file before saving.
- [x] Integrate file sharing:
  - [x] Allow sharing PDFs via email, messenger, Google Drive, etc.
  - [x] Implement an option to open the folder containing the saved file.
- [x] Write tests to verify:
  - [x] Unique filenames are generated correctly.
  - [x] File sharing interface launches as expected.
  - [x] Renaming functionality works and is persisted.

## 7. Multi-language Support
- [x] Add multi-language support using Flutter localization:
  - [x] Configure `flutter_localizations` in `pubspec.yaml`.
  - [x] Create localization files (e.g., ARB files) for English, Spanish, French, German, Chinese, and Vietnamese.
  - [x] Update the MaterialApp to support localization and language switching.
  - [x] Add a settings screen or mechanism for users to select their preferred language.
  - [x] Update all UI strings (Home Screen, PDF Viewer, dialogs, etc.) to be translatable.
- [x] Write tests to verify:
  - [x] The app displays text in the selected language.
  - [x] Switching languages updates all UI elements appropriately.

## 8. Error Handling, Security & Edge Cases
- [x] Implement error handling for:
  - [x] Password-protected PDFs:
    - [x] Prompt for a password.
    - [x] Allow retries if the password is incorrect.
  - [x] Corrupt PDF files:
    - [x] Detect and show a warning if a PDF page fails to load.
    - [x] Allow users to continue viewing other pages.
  - [x] Large PDF files (>50MB):
    - [x] Display a warning.
    - [x] Show a progress indicator while loading.
  - [x] Slow scrolling:
    - [x] Throttle excessive scrolling to avoid lag or crashes.
  - [x] Handling unsaved changes:
    - [x] Auto-save a draft when exiting during editing.
    - [x] Prompt the user to resume unsaved sessions upon reopening.
- [x] Write tests to simulate these error scenarios and verify proper handling.

## 9. Final Integration & End-to-End Testing
- [x] Integrate all modules:
  - [x] Ensure smooth navigation and data flow between Home Screen, PDF Viewer, file management, editing tools, multi-language support, and error handling.
- [x] Verify that all functionalities are accessible from the main user flow:
  - [x] Opening the app, selecting and viewing a PDF.
  - [x] Editing the PDF (annotations, highlights, deletion) and using undo.
  - [x] Saving the edited PDF with a new filename.
  - [x] File sharing and recent files management.
  - [x] Switching between languages and verifying that UI strings update accordingly.
- [x] Write comprehensive end-to-end tests to simulate:
  - [x] Full user journeys covering all key functionalities.
  - [x] Persistence and error handling scenarios.
- [x] Ensure there is no orphaned or unintegrated code.
