# Flutter PDF Viewer & Editor - Testing Guide

This document provides instructions on how to run the tests for the Flutter PDF Viewer & Editor application.

## Prerequisites

- Flutter SDK installed and configured
- Android Studio or VS Code with Flutter extensions
- A connected device or emulator

## Running the Tests

### Unit Tests

To run all unit tests, use the following command:

```bash
flutter test
```

To run a specific test file, use:

```bash
flutter test test/file_name_test.dart
```

### Widget Tests

Widget tests are included in the test files and can be run using the same commands as unit tests.

### Integration Tests

To run the integration tests, use:

```bash
flutter test integration_test
```

## Test Coverage

To generate a test coverage report, use:

```bash
flutter test --coverage
```

Then, to view the coverage report in HTML format, use:

```bash
genhtml coverage/lcov.info -o coverage/html
```

And open `coverage/html/index.html` in your browser.

## Test Files

- `error_handling_test.dart`: Tests for error handling functionality
- `file_management_test.dart`: Tests for file management functionality
- `file_sharing_test.dart`: Tests for file sharing functionality
- `home_screen_file_management_test.dart`: Tests for file management in the home screen
- `home_screen_test.dart`: Tests for the home screen
- `home_screen_ui_test.dart`: Tests for the home screen UI
- `integration_test.dart`: End-to-end integration tests
- `localization_test.dart`: Tests for localization functionality
- `pdf_editing_test.dart`: Tests for PDF editing functionality
- `pdf_editing_toolbar_test.dart`: Tests for the PDF editing toolbar
- `pdf_saving_test.dart`: Tests for PDF saving functionality
- `pdf_viewer_test.dart`: Tests for the PDF viewer screen
- `widget_test.dart`: Basic widget tests

## Manual Testing Checklist

1. **Home Screen**
   - [ ] Open the app and verify the home screen is displayed
   - [ ] Verify that the recent files list is displayed (if any)
   - [ ] Tap on the "Open PDF" button and select a PDF file
   - [ ] Verify that the PDF viewer screen is displayed

2. **PDF Viewer Screen**
   - [ ] Verify that the PDF is displayed correctly
   - [ ] Swipe left/right to navigate between pages
   - [ ] Pinch to zoom in/out
   - [ ] Double-tap to zoom in/out
   - [ ] Verify that the page indicator shows the correct page number

3. **PDF Editing**
   - [ ] Tap on the edit button to enter editing mode
   - [ ] Add an annotation to the PDF
   - [ ] Highlight text in the PDF
   - [ ] Delete a page from the PDF
   - [ ] Undo the last operation
   - [ ] Save the edited PDF with a new filename

4. **File Sharing**
   - [ ] Tap on the share button in the PDF viewer
   - [ ] Verify that the share options are displayed
   - [ ] Share the PDF file
   - [ ] Open the folder containing the PDF file

5. **Error Handling**
   - [ ] Try to open a password-protected PDF
   - [ ] Verify that the password dialog is displayed
   - [ ] Enter the correct password and verify that the PDF is displayed
   - [ ] Try to open a corrupt PDF
   - [ ] Verify that the error dialog is displayed
   - [ ] Try to open a large PDF
   - [ ] Verify that the warning dialog is displayed

6. **Localization**
   - [ ] Go to the settings screen
   - [ ] Change the language
   - [ ] Verify that the app displays text in the selected language 