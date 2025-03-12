# Flutter PDF Viewer & Editor - Step-by-Step Blueprint

This blueprint breaks the project into phases and further divides them into small, iterative prompts. Each prompt is designed for a code-generation LLM to implement in a test-driven manner. All code pieces are integrated step-by-step, ensuring no orphaned code exists.

---

## Overall Project Blueprint

1. **Project Setup & Initial Configuration**  
   - Create a new Flutter project  
   - Add dependencies:
     - `syncfusion_flutter_pdfviewer`
     - `syncfusion_flutter_pdf`
     - State management package (Provider or Riverpod)
     - `path_provider`
     - `permission_handler`
     - `shared_preferences`
   - Set up the repository and basic CI/CD pipeline  
   - Confirm that a basic "Hello World" UI runs correctly with initial tests

2. **Core UI & Navigation**  
   - Build a Home Screen with an “Open File” button and a Recent Files list  
   - Establish navigation between Home Screen and PDF Viewer Screen

3. **PDF Viewing Functionality**  
   - Integrate `syncfusion_flutter_pdfviewer` to display PDFs  
   - Implement smooth scrolling, pinch-to-zoom, double-tap zoom, and page navigation controls  
   - Store the last viewed page using local persistence

4. **PDF Editing Features**  
   - Integrate `syncfusion_flutter_pdf` for annotations, highlighting, and page deletion  
   - Add UI elements (floating toolbars) for editing actions  
   - Implement undo support for editing actions

5. **File Management & Sharing**  
   - Implement file picking and permission handling  
   - Manage a Recent Files list (with search, filter, and swipe-to-delete)
   - Enable file sharing (renaming, opening file location, sharing via different channels)

6. **Error Handling & Security**  
   - Handle password-protected PDFs, corrupt file errors, large file warnings, and unsaved changes  
   - Provide user-friendly error messages and confirmations

7. **Testing & Integration**  
   - Write unit and widget tests for each module  
   - Conduct end-to-end integration tests ensuring a seamless user flow

---

## Iterative Prompts

Each prompt below is formatted as a separate code block tagged as text.

---

### **Prompt 1: Project Setup and Repository Initialization**

```text
# Prompt 1: Project Setup and Repository Initialization

We are building a Flutter PDF Viewer & Editor app. Start by creating a new Flutter project and set up the project repository with CI/CD (if available). Then, add the required dependencies to `pubspec.yaml`, including:

- syncfusion_flutter_pdfviewer
- syncfusion_flutter_pdf
- provider (or riverpod, based on our chosen state management)
- path_provider
- permission_handler
- shared_preferences

Ensure that the basic project builds and runs a simple “Hello World” UI. Write tests for basic app startup to ensure the project is set up correctly.

The code should include:
- A basic `main.dart` with a MaterialApp and a HomeScreen placeholder.
- A test file that verifies the app launches without errors.
- Instructions for setting up CI/CD if applicable.

End with wiring this initial setup together and confirming that the app runs.
```

---

### **Prompt 2: Build Home Screen and Navigation Setup**

```text
# Prompt 2: Build Home Screen and Navigation Setup

Extend the project by building the Home Screen. The Home Screen should include:
- A large centered “Open File” button.
- A list view to display up to 10 recent files (placeholder data is acceptable for now).
- A Floating Action Button (FAB) for quick access (e.g., refresh list).

Implement navigation such that tapping the “Open File” button navigates to the PDF Viewer Screen. Create a basic PDF Viewer Screen scaffold that will later host the PDF viewer.

Also, write a widget test to verify that:
- The Home Screen renders correctly.
- Tapping the “Open File” button navigates to the PDF Viewer Screen.

Make sure that the navigation is wired correctly so that there are no orphaned screens.
```

---

### **Prompt 3: Implement PDF Viewing Screen and Basic PDF Rendering**

```text
# Prompt 3: Implement PDF Viewing Screen and Basic PDF Rendering

Using the `syncfusion_flutter_pdfviewer` package, integrate PDF viewing functionality into the PDF Viewer Screen. The requirements are:
- Open a local PDF file (use a sample asset for now).
- Support smooth scrolling, pinch-to-zoom, and double-tap zoom.
- Include navigation controls (previous/next buttons, page indicator).

Wire these elements together so that:
- The user can navigate through pages.
- The last viewed page is stored locally (e.g., using Shared Preferences).

Write tests to verify that:
- A sample PDF is rendered correctly.
- Navigation controls update the page view appropriately.
- The last viewed page is correctly stored and reloaded on app restart.
```

---

### **Prompt 4: File Management and Recent Files Functionality**

```text
# Prompt 4: File Management and Recent Files Functionality

Enhance the app with file management features:
- Integrate file picking to allow the user to select a PDF from local storage.
- Request and manage necessary permissions using `permission_handler`.
- Implement a Recent Files list that stores up to 10 files, sorted by the last accessed time, and supports searching/filtering by file name.
- Add the ability to remove an entry from the Recent Files list via a swipe-to-delete gesture (this should not delete the actual file).

Ensure to write tests for:
- File picker functionality (simulate file selection).
- Correct addition and removal of files in the Recent Files list.
- Persistence of recent files between app sessions using Shared Preferences.
```

---

### **Prompt 5: Implement PDF Editing (Annotations, Highlighting, Delete Page)**

```text
# Prompt 5: Implement PDF Editing (Annotations, Highlighting, Delete Page)

Integrate the `syncfusion_flutter_pdf` package to enable editing functionalities. Implement the following features:
- **Annotations:** Allow users to add text notes to any position on the PDF.
- **Highlighting:** Enable text selection and highlighting (default yellow with 50% transparency).
- **Delete Page:** Provide an option to delete the current page with a confirmation prompt.
- **Undo Support:** Allow the user to undo the last editing action (annotation, highlight, or deletion) before saving.

Wire these editing options to the UI using a floating toolbar with appropriate icons.

Develop tests to:
- Validate that annotations and highlights are applied and visually rendered.
- Confirm that deletion of a page works as expected.
- Verify that the undo functionality correctly reverses the last editing action.
```

---

### **Prompt 6: Implement Saving, Exporting, and File Sharing**

```text
# Prompt 6: Implement Saving, Exporting, and File Sharing

Add functionality for saving the edited PDF:
- On saving, create a new file in the same directory as the original, using a filename pattern (e.g., document_edited(1).pdf) to avoid overwrites.
- Integrate an option for renaming the file before saving.
- Implement file sharing functionality (using share packages or platform channels) to allow users to share PDFs via email, messenger, Google Drive, etc.
- Include an option to open the folder containing the saved file.

Write tests to:
- Verify that the PDF is saved with a unique filename.
- Confirm that the file sharing interface is launched correctly.
- Validate that renaming functionality works and is persisted.
```

---

### Prompt 7: Add Multi-language Support
```text
# Prompt 7: Add Multi-language Support

Integrate multi-language support to allow the app to display content in English, Spanish, French, German, Chinese, and Vietnamese. Steps include:
- Add the `flutter_localizations` package and configure it in `pubspec.yaml`.
- Create localization files (e.g., ARB files) for each supported language containing all necessary UI strings.
- Update the app's MaterialApp configuration to support localization and language switching.
- Provide a mechanism (e.g., settings menu) for users to select their preferred language.
- Wire multi-language support into the Home Screen, PDF Viewer Screen, and all dialogs/messages.
  
Write tests to:
- Verify that the app displays text in the selected language.
- Ensure that switching languages updates all UI elements appropriately.
```
---

### **Prompt 8: Error Handling, Security, and Edge Cases**

```text
# Prompt 8: Error Handling, Security, and Edge Cases

Incorporate robust error handling and security measures:
- **Password-Protected PDFs:** Prompt for a password and allow retries if incorrect.
- **Corrupt PDF Handling:** Detect if a PDF page fails to load, show a warning, and allow the user to continue.
- **Large Files (>50MB):** Display a warning and a progress indicator when loading large files.
- **Slow Scrolling Protection:** Ensure that excessive scrolling is throttled to prevent lag or crashes.
- **Handling Unsaved Changes:** Auto-save a draft when the user exits during editing, and prompt on reopening to resume the session.

Write tests to simulate:
- Opening a password-protected PDF (using mocks or test doubles).
- Loading a corrupt PDF file and verifying error messages.
- Handling unsaved changes and resuming sessions.
```

---

### **Prompt 9: Final Integration and End-to-End Testing**

```text
# Prompt 9: Final Integration and End-to-End Testing

Now that all components are built, integrate all modules together:
- Wire the Home Screen, PDF Viewer Screen, file management, editing tools, and error handling into a cohesive workflow.
- Ensure navigation flows smoothly between screens.
- Confirm that data persists appropriately (e.g., last viewed page, recent files list).
- Conduct end-to-end tests that simulate a full user journey:
  1. Opening the app, selecting a PDF, and navigating the PDF.
  2. Editing the PDF (adding annotations, highlights, and deleting a page) and then undoing an action.
  3. Saving the edited PDF with a new filename.
  4. Using file sharing and verifying that the recent files list updates.
  5. Handling errors gracefully (password-protection, corrupt file warnings, etc.).

Provide test scripts or guidance for automated widget and integration tests. Confirm that all parts of the app are linked together with no orphaned code, and that every feature is accessible and testable from the main flow.
```
