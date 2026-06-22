# Match Sheet Flutter App

A Flutter application for processing and displaying match sheet documents (.docx).

## Quick Start

### Prerequisites
- Flutter SDK installed ([Download here](https://flutter.dev/docs/get-started/install))
- Document file: `match sheet.docx`

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/
│   └── match_entry.dart     # Data models
├── services/
│   └── document_service.dart # Document processing
├── screens/
│   └── home_screen.dart     # Main UI
└── widgets/
    └── (Custom widgets)
```

## Features

- Load and parse DOCX documents
- Display match sheet data
- Process and organize match entries

## Development Notes

- Fast build times with hot reload
- Modular architecture for easy expansion
- Document parsing service ready for implementation

## Next Steps

1. Install Flutter SDK if not already done
2. Run `flutter pub get`
3. Customize document parsing in `lib/services/document_service.dart`
4. Extend UI components as needed

flutter doctor


flutter create . --platforms=web

flutter run -d

List available devices:
flutter devices

Launch the app:
flutter run -d chrome
flutter run -d edge