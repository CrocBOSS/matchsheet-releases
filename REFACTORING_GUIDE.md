# Refactoring Guide - Step by Step

## 🎯 Goal
Transform the current codebase into a modular, maintainable architecture without breaking existing functionality.

---

## 📋 Phase 1: Core Infrastructure (Start Here)

### Step 1.1: Create Core Folder Structure

```bash
lib/
├── core/
│   ├── models/
│   ├── services/
│   │   ├── storage/
│   │   ├── export/
│   │   └── share/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   └── layouts/
│   └── utils/
```

### Step 1.2: Create Base Models

**File: `lib/core/models/base_player.dart`**
```dart
/// Base player model that all sport players extend
abstract class BasePlayer {
  final int id;
  final int number;
  final String name;
  final String position;
  final String teamName;
  final String comments;
  final int rating;

  BasePlayer({
    required this.id,
    required this.number,
    required this.name,
    required this.position,
    this.teamName = '',
    this.comments = '',
    this.rating = 0,
  });

  Map<String, dynamic> toJson();
  
  // Common methods all players need
  String get displayName => '$number - $name';
  bool get hasRating => rating > 0;
}
```

**File: `lib/core/models/base_stat.dart`**
```dart
/// Base stat model
class BaseStat {
  final String key;
  final String label;
  final int value;

  BaseStat({
    required this.key,
    required this.label,
    this.value = 0,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'value': value,
  };

  factory BaseStat.fromJson(Map<String, dynamic> json) => BaseStat(
    key: json['key'] as String,
    label: json['label'] as String,
    value: json['value'] as int? ?? 0,
  );
}
```

### Step 1.3: Create Repository Interface

**File: `lib/core/services/storage/storage_repository.dart`**
```dart
/// Generic repository interface for CRUD operations
abstract class StorageRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> update(String id, T item);
  Future<void> delete(String id);
  Future<void> clear();
}
```

**File: `lib/core/services/storage/local_storage_repository.dart`**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_repository.dart';

/// Implementation of StorageRepository using SharedPreferences
class LocalStorageRepository<T> implements StorageRepository<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  LocalStorageRepository({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
  });

  @override
  Future<List<T>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading from storage: $e');
      return [];
    }
  }

  @override
  Future<T?> getById(String id) async {
    final items = await getAll();
    try {
      return items.firstWhere(
        (item) => _getId(item) == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(T item) async {
    final items = await getAll();
    items.add(item);
    await _saveAll(items);
  }

  @override
  Future<void> update(String id, T item) async {
    final items = await getAll();
    final index = items.indexWhere((i) => _getId(i) == id);
    
    if (index >= 0) {
      items[index] = item;
      await _saveAll(items);
    }
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((item) => _getId(item) == id);
    await _saveAll(items);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }

  Future<void> _saveAll(List<T> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => toJson(item)).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving to storage: $e');
      rethrow;
    }
  }

  String _getId(T item) {
    final json = toJson(item);
    return json['id']?.toString() ?? '';
  }
}
```

### Step 1.4: Create Export Service Interface

**File: `lib/core/services/export/export_strategy.dart`**
```dart
/// Strategy interface for different export formats
abstract class ExportStrategy {
  String get fileExtension;
  String get mimeType;
  
  Future<List<int>> export(dynamic data);
}
```

**File: `lib/core/services/export/txt_export_strategy.dart`**
```dart
import 'export_strategy.dart';

class TxtExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'txt';
  
  @override
  String get mimeType => 'text/plain';

  @override
  Future<List<int>> export(dynamic data) async {
    if (data is String) {
      return data.codeUnits;
    }
    throw ArgumentError('TxtExportStrategy requires String data');
  }
}
```

**File: `lib/core/services/export/excel_export_strategy.dart`**
```dart
import 'package:excel/excel.dart';
import 'export_strategy.dart';

class ExcelExportStrategy implements ExportStrategy {
  @override
  String get fileExtension => 'xlsx';
  
  @override
  String get mimeType => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  @override
  Future<List<int>> export(dynamic data) async {
    if (data is Excel) {
      return data.encode()!;
    }
    throw ArgumentError('ExcelExportStrategy requires Excel data');
  }
}
```

**File: `lib/core/services/export/export_service.dart`**
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'export_strategy.dart';

class ExportService {
  Future<void> exportAndShare({
    required dynamic data,
    required ExportStrategy strategy,
    required String fileName,
    String? subject,
  }) async {
    try {
      // Export data using strategy
      final bytes = await strategy.export(data);
      
      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.${strategy.fileExtension}');
      await file.writeAsBytes(bytes);
      
      // Share the file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? 'Export',
      );
    } catch (e) {
      throw ExportException('Failed to export: $e');
    }
  }
}

class ExportException implements Exception {
  final String message;
  ExportException(this.message);
  
  @override
  String toString() => message;
}
```

### Step 1.5: Create Reusable Widgets

**File: `lib/core/widgets/dialogs/export_format_dialog.dart`**
```dart
import 'package:flutter/material.dart';

enum ExportFormat { txt, excel }

class ExportFormatDialog extends StatelessWidget {
  const ExportFormatDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Format', style: TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select export format:',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Text File (.txt)', style: TextStyle(fontSize: 13)),
            onTap: () => Navigator.pop(context, ExportFormat.txt),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Excel File (.xlsx)', style: TextStyle(fontSize: 13)),
            onTap: () => Navigator.pop(context, ExportFormat.excel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  static Future<ExportFormat?> show(BuildContext context) {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => const ExportFormatDialog(),
    );
  }
}
```

**File: `lib/core/widgets/buttons/primary_button.dart`**
```dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(label),
    );
  }
}
```

---

## 📋 Phase 2: Refactor Existing Code

### Step 2.1: Refactor Soccer Module

**Create: `lib/features/sports/soccer/models/soccer_player.dart`**
```dart
import '../../../../core/models/base_player.dart';

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

  factory SoccerPlayer.fromJson(Map<String, dynamic> json) {
    return SoccerPlayer(
      id: json['id'] as int,
      number: json['number'] as int,
      name: json['name'] as String,
      position: json['position'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      firstHalfStats: (json['firstHalfStats'] as Map<String, dynamic>?)?.cast<String, int>() ?? {},
      secondHalfStats: (json['secondHalfStats'] as Map<String, dynamic>?)?.cast<String, int>() ?? {},
    );
  }

  SoccerPlayer copyWith({
    int? id,
    int? number,
    String? name,
    String? position,
    String? teamName,
    String? comments,
    int? rating,
    Map<String, int>? firstHalfStats,
    Map<String, int>? secondHalfStats,
  }) {
    return SoccerPlayer(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      position: position ?? this.position,
      teamName: teamName ?? this.teamName,
      comments: comments ?? this.comments,
      rating: rating ?? this.rating,
      firstHalfStats: firstHalfStats ?? this.firstHalfStats,
      secondHalfStats: secondHalfStats ?? this.secondHalfStats,
    );
  }
}
```

**Create: `lib/features/sports/soccer/services/soccer_match_service.dart`**
```dart
import '../../../../core/services/storage/storage_repository.dart';
import '../models/soccer_player.dart';

class SoccerMatchService {
  final StorageRepository<SoccerPlayer> _playerRepository;

  SoccerMatchService(this._playerRepository);

  Future<List<SoccerPlayer>> getPlayers() => _playerRepository.getAll();

  Future<void> savePlayer(SoccerPlayer player) => _playerRepository.save(player);

  Future<void> updatePlayer(SoccerPlayer player) => 
    _playerRepository.update(player.id.toString(), player);

  Future<void> deletePlayer(String id) => _playerRepository.delete(id);

  // Business logic methods
  int calculateTotalStats(SoccerPlayer player, String statKey) {
    final firstHalf = player.firstHalfStats[statKey] ?? 0;
    final secondHalf = player.secondHalfStats[statKey] ?? 0;
    return firstHalf + secondHalf;
  }

  Map<String, int> getFullMatchStats(SoccerPlayer player) {
    final stats = <String, int>{};
    
    // Combine first and second half
    for (final key in player.firstHalfStats.keys) {
      stats[key] = calculateTotalStats(player, key);
    }
    
    return stats;
  }
}
```

### Step 2.2: Example Usage in Screen

**Refactored: `lib/features/sports/soccer/screens/soccer_match_screen.dart`**
```dart
import 'package:flutter/material.dart';
import '../../../../core/services/export/export_service.dart';
import '../../../../core/services/export/txt_export_strategy.dart';
import '../../../../core/services/export/excel_export_strategy.dart';
import '../../../../core/widgets/dialogs/export_format_dialog.dart';
import '../services/soccer_match_service.dart';
import '../models/soccer_player.dart';

class SoccerMatchScreen extends StatefulWidget {
  const SoccerMatchScreen({Key? key}) : super(key: key);

  @override
  State<SoccerMatchScreen> createState() => _SoccerMatchScreenState();
}

class _SoccerMatchScreenState extends State<SoccerMatchScreen> {
  late final SoccerMatchService _matchService;
  late final ExportService _exportService;
  
  List<SoccerPlayer> players = [];

  @override
  void initState() {
    super.initState();
    // Initialize services (in real app, use dependency injection)
    _matchService = SoccerMatchService(/* repository */);
    _exportService = ExportService();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final loadedPlayers = await _matchService.getPlayers();
    setState(() {
      players = loadedPlayers;
    });
  }

  Future<void> _exportMatch() async {
    // Show format dialog
    final format = await ExportFormatDialog.show(context);
    if (format == null) return;

    try {
      if (format == ExportFormat.txt) {
        // Generate text data
        final textData = _generateTextData();
        
        await _exportService.exportAndShare(
          data: textData,
          strategy: TxtExportStrategy(),
          fileName: 'match_${DateTime.now().millisecondsSinceEpoch}',
          subject: 'Match Sheet Export',
        );
      } else {
        // Generate Excel data
        final excelData = _generateExcelData();
        
        await _exportService.exportAndShare(
          data: excelData,
          strategy: ExcelExportStrategy(),
          fileName: 'match_${DateTime.now().millisecondsSinceEpoch}',
          subject: 'Match Sheet Export',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  String _generateTextData() {
    // Generate text format
    return 'Match data...';
  }

  dynamic _generateExcelData() {
    // Generate Excel format
    return null; // Excel object
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soccer Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportMatch,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            title: Text(player.displayName),
            subtitle: Text(player.position),
          );
        },
      ),
    );
  }
}
```

---

## 🎯 Quick Wins (Do These First)

### 1. Extract Export Dialog (30 minutes)
- Create `ExportFormatDialog` widget
- Replace all export dialogs with this widget
- Immediate benefit: Consistent UI, less code duplication

### 2. Create Export Service (1 hour)
- Create `ExportService` with strategies
- Replace direct export code with service calls
- Immediate benefit: Easy to add new export formats

### 3. Extract Common Widgets (2 hours)
- Move `StatCounterBox` to `core/widgets/`
- Move `PlayerListPanel` to `core/widgets/`
- Immediate benefit: Reuse across all sports

### 4. Create Repository for Players (2 hours)
- Create `PlayerRepository`
- Replace direct `SharedPreferences` calls
- Immediate benefit: Easier to test, cleaner code

---

## 📊 Progress Tracking

Create a checklist:

```markdown
## Refactoring Progress

### Phase 1: Core Infrastructure
- [ ] Create folder structure
- [ ] Create base models
- [ ] Create repository interface
- [ ] Create export service
- [ ] Create common widgets

### Phase 2: Soccer Module
- [ ] Create soccer models
- [ ] Create soccer service
- [ ] Refactor soccer screen
- [ ] Test soccer module

### Phase 3: Basketball Module
- [ ] Create basketball models
- [ ] Create basketball service
- [ ] Refactor basketball screen
- [ ] Test basketball module

### Phase 4: Training Module
- [ ] Create training models
- [ ] Create training service
- [ ] Refactor training screens
- [ ] Test training module

### Phase 5: Testing & Documentation
- [ ] Add unit tests
- [ ] Add widget tests
- [ ] Update documentation
- [ ] Code review
```

---

## 🚨 Common Pitfalls to Avoid

1. **Don't refactor everything at once**
   - ❌ Rewrite entire app
   - ✅ Refactor one module at a time

2. **Don't break existing functionality**
   - ❌ Change behavior during refactoring
   - ✅ Keep same behavior, improve structure

3. **Don't skip testing**
   - ❌ Refactor without tests
   - ✅ Test after each change

4. **Don't over-engineer**
   - ❌ Add complex patterns you don't need
   - ✅ Start simple, add complexity when needed

---

## 💡 Tips for Success

1. **Commit frequently**: After each successful refactoring step
2. **Test thoroughly**: Run the app after each change
3. **Keep notes**: Document what you changed and why
4. **Ask for help**: If stuck, review the architecture doc
5. **Be patient**: Good architecture takes time

---

**Ready to start? Begin with Phase 1, Step 1.1!**
