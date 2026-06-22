# Quick Reference - Core Infrastructure

## 📚 Documentation Index

| Document | Purpose | When to Read |
|----------|---------|--------------|
| `ARCHITECTURE.md` | Overall architecture plan | Planning new features |
| `REFACTORING_GUIDE.md` | Step-by-step implementation | Migrating existing code |
| `CODEBASE_ANALYSIS.md` | Current codebase analysis | Understanding the app |
| `PHASE1_PROGRESS.md` | Detailed progress tracking | Checking what was done |
| `PHASE1_SUMMARY.md` | Benefits and achievements | Understanding value |
| `PHASE1_VISUAL_GUIDE.md` | Visual diagrams | Quick visual reference |
| `QUICK_REFERENCE.md` | This file | Quick lookups |

## 🗂️ Core File Locations

### Models
```
lib/core/models/
├── base_player.dart      # Abstract base for all players
└── base_stat.dart        # Base stat model
```

### Storage
```
lib/core/services/storage/
├── storage_repository.dart          # Interface
└── local_storage_repository.dart    # Implementation
```

### Export
```
lib/core/services/export/
├── export_strategy.dart         # Interface
├── export_service.dart          # Main service
├── txt_export_strategy.dart     # Text export
└── excel_export_strategy.dart   # Excel export
```

### Widgets
```
lib/core/widgets/
├── cards/
│   └── stat_counter_box.dart           # Stat counter
├── dialogs/
│   └── export_format_dialog.dart       # Format selector
└── layouts/
    └── player_list_panel.dart          # Player list
```

### Utils
```
lib/core/utils/
└── dialog_helpers.dart    # Reusable dialogs
```

## 💻 Code Snippets

### 1. Using Repository Pattern
```dart
// Create repository
final repository = LocalStorageRepository<Player>(
  storageKey: 'players',
  fromJson: Player.fromJson,
  toJson: (p) => p.toJson(),
);

// CRUD operations
final players = await repository.getAll();
await repository.save(newPlayer);
await repository.update('1', updatedPlayer);
await repository.delete('1');
await repository.clear();
```

### 2. Using Export Service
```dart
// Import
import 'package:matchsheet/core/services/export/export_service.dart';
import 'package:matchsheet/core/services/export/txt_export_strategy.dart';
import 'package:matchsheet/core/services/export/excel_export_strategy.dart';
import 'package:matchsheet/core/widgets/dialogs/export_format_dialog.dart';

// Show format dialog
final format = await ExportFormatDialog.show(context);
if (format == null) return;

// Create service
final exportService = ExportService();

// Export
if (format == ExportFormat.txt) {
  await exportService.exportAndShare(
    data: 'Your text data here',
    strategy: TxtExportStrategy(),
    fileName: 'export_${DateTime.now().millisecondsSinceEpoch}',
    subject: 'Data Export',
  );
} else {
  await exportService.exportAndShare(
    data: yourExcelObject,
    strategy: ExcelExportStrategy(),
    fileName: 'export_${DateTime.now().millisecondsSinceEpoch}',
    subject: 'Data Export',
  );
}
```

### 3. Using Core Widgets
```dart
// Import
import 'package:matchsheet/core/widgets/cards/stat_counter_box.dart';
import 'package:matchsheet/core/widgets/layouts/player_list_panel.dart';
import 'package:matchsheet/core/widgets/dialogs/export_format_dialog.dart';

// StatCounterBox
StatCounterBox(
  label: 'Goals',
  value: goals,
  onIncrement: () => setState(() => goals++),
  onDecrement: () => setState(() => goals > 0 ? goals-- : null),
)

// PlayerListPanel
PlayerListPanel(
  players: players,
  selectedPlayerId: selectedPlayer?.id,
  onPlayerSelected: (player) => setState(() => selectedPlayer = player),
  onAddPlayer: () => _showAddPlayerDialog(),
)

// ExportFormatDialog
final format = await ExportFormatDialog.show(context);
```

### 4. Using Dialog Helpers
```dart
// Import
import 'package:matchsheet/core/utils/dialog_helpers.dart';

// Text input dialog
await DialogHelpers.showTextInputDialog(
  context: context,
  title: 'Add Comment',
  initialText: player.comments,
  labelText: 'Comment',
  onSave: (text) {
    setState(() {
      player.comments = text;
    });
  },
);

// Rating dialog
await DialogHelpers.showRatingDialog(
  context: context,
  title: 'Rate Player',
  currentRating: player.rating,
  onRate: (rating) {
    setState(() {
      player.rating = rating;
    });
  },
);
```

### 5. Extending Base Models
```dart
// Import
import 'package:matchsheet/core/models/base_player.dart';

// Create your player class
class SoccerPlayer extends BasePlayer {
  final Map<String, int> firstHalfStats;
  final Map<String, int> secondHalfStats;

  SoccerPlayer({
    required super.id,
    required super.number,
    required super.name,
    required super.position,
    super.teamName,
    super.comments,
    super.rating,
    Map<String, int>? firstHalfStats,
    Map<String, int>? secondHalfStats,
  })  : firstHalfStats = firstHalfStats ?? {},
        secondHalfStats = secondHalfStats ?? {};

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'name': name,
    'position': position,
    'teamName': teamName,
    'comments': comments,
    'rating': rating,
    'firstHalfStats': firstHalfStats,
    'secondHalfStats': secondHalfStats,
  };

  // Use inherited methods
  // displayName, hasRating, hasComments, ratingDisplay
}
```

## 🎯 Common Tasks

### Task: Add a new export format (e.g., PDF)

1. Create strategy:
```dart
// lib/core/services/export/pdf_export_strategy.dart
import 'export_strategy.dart';

class PdfExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'pdf';

  @override
  String get mimeType => 'application/pdf';

  @override
  Future<List<int>> export(dynamic data) async {
    // Your PDF generation logic
    return pdfBytes;
  }
}
```

2. Update dialog:
```dart
// Add to ExportFormatDialog
enum ExportFormat { txt, excel, pdf }

// Add option in dialog
ListTile(
  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
  title: const Text('PDF File (.pdf)'),
  onTap: () => Navigator.pop(context, ExportFormat.pdf),
)
```

3. Use in screen:
```dart
if (format == ExportFormat.pdf) {
  await exportService.exportAndShare(
    data: pdfData,
    strategy: PdfExportStrategy(),
    fileName: 'export',
  );
}
```

### Task: Add a new storage backend (e.g., SQLite)

1. Create repository:
```dart
// lib/core/services/storage/sqlite_repository.dart
import 'storage_repository.dart';

class SqliteRepository<T> implements StorageRepository<T> {
  // Implement all methods using SQLite
  @override
  Future<List<T>> getAll() async {
    // SQLite query logic
  }
  
  // ... other methods
}
```

2. Use in your code:
```dart
final repository = SqliteRepository<Player>(
  tableName: 'players',
  fromMap: Player.fromJson,
  toMap: (p) => p.toJson(),
);
```

### Task: Create a reusable widget

1. Add to core:
```dart
// lib/core/widgets/cards/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  // Your widget implementation
}
```

2. Use in screens:
```dart
import 'package:matchsheet/core/widgets/cards/my_widget.dart';

MyWidget(...)
```

## 🚨 Important Notes

### Data Storage Pattern
```dart
// First half stats
player.customStats['goals'] = 2;

// Second half stats
player.secondHalfStats['goals'] = 1;

// Individual fields (always 0)
player.goals = 0;  // Don't use this!
```

### Import Paths
```dart
// Core imports (new)
import 'package:matchsheet/core/models/base_player.dart';
import 'package:matchsheet/core/services/export/export_service.dart';
import 'package:matchsheet/core/widgets/cards/stat_counter_box.dart';

// Old imports (still work)
import '../models/match_entry.dart';
import '../services/storage_service.dart';
import '../widgets/stat_counter_box.dart';
```

### Backward Compatibility
- ✅ Old code still works
- ✅ Old imports still work
- ✅ SharedPreferences keys unchanged
- ✅ JSON structure unchanged

## 📞 Need Help?

### Question: How do I...?

**...use the repository pattern?**
→ See "Using Repository Pattern" above

**...export data?**
→ See "Using Export Service" above

**...use core widgets?**
→ See "Using Core Widgets" above

**...extend base models?**
→ See "Extending Base Models" above

**...add a new export format?**
→ See "Task: Add a new export format" above

### Question: Where is...?

**...the player model?**
→ `lib/models/match_entry.dart` (old)
→ `lib/core/models/base_player.dart` (new base)

**...the storage service?**
→ `lib/services/storage_service.dart` (old)
→ `lib/core/services/storage/` (new)

**...the export logic?**
→ `lib/services/storage_service.dart` (old)
→ `lib/core/services/export/` (new)

**...the widgets?**
→ `lib/widgets/` (old)
→ `lib/core/widgets/` (new)

## 🎓 Learning Resources

### Read in Order
1. `ARCHITECTURE.md` - Big picture
2. `CODEBASE_ANALYSIS.md` - Current state
3. `PHASE1_VISUAL_GUIDE.md` - Visual overview
4. `QUICK_REFERENCE.md` - This file
5. Start coding!

### Design Patterns Used
- **Repository Pattern** - Data access abstraction
- **Strategy Pattern** - Interchangeable algorithms
- **Template Method** - Base class with common behavior

### Best Practices
- ✅ Use core infrastructure for new features
- ✅ Keep old code working during migration
- ✅ Test after each change
- ✅ Document as you go
- ✅ Commit frequently

## 🎉 Quick Wins

### Easy Improvements You Can Make Now

1. **Use ExportFormatDialog** in all export features
2. **Use DialogHelpers** instead of custom dialogs
3. **Use StatCounterBox** from core in new screens
4. **Use PlayerListPanel** from core in new screens
5. **Create new features using Repository pattern**

---

**Remember**: The core infrastructure is there to help you, not to force you to rewrite everything. Use it when it makes sense, and keep the old code working!

🚀 **Happy coding!**
