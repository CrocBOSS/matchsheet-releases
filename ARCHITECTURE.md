# Match Sheet App - Modular Architecture Plan

## 🎯 Goals
- **Maintainability**: Easy to understand and modify
- **Scalability**: Easy to add new sports/features
- **Reusability**: Share code between modules
- **Testability**: Easy to test individual components

---

## 📁 Proposed Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                          # Main app widget
│   ├── routes.dart                       # Route definitions
│   └── theme.dart                        # App theme
│
├── core/                                 # Core functionality (shared across all modules)
│   ├── models/
│   │   ├── base_player.dart             # Base player model
│   │   ├── base_stat.dart               # Base stat model
│   │   └── base_session.dart            # Base session model
│   │
│   ├── services/
│   │   ├── storage/
│   │   │   ├── storage_service.dart     # Abstract storage interface
│   │   │   ├── local_storage.dart       # SharedPreferences implementation
│   │   │   └── storage_repository.dart  # Repository pattern
│   │   │
│   │   ├── export/
│   │   │   ├── export_service.dart      # Abstract export interface
│   │   │   ├── txt_exporter.dart        # Text export implementation
│   │   │   ├── excel_exporter.dart      # Excel export implementation
│   │   │   └── pdf_exporter.dart        # Future: PDF export
│   │   │
│   │   └── share/
│   │       └── share_service.dart       # File sharing service
│   │
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   └── icon_button.dart
│   │   │
│   │   ├── cards/
│   │   │   ├── stat_card.dart
│   │   │   └── player_card.dart
│   │   │
│   │   ├── dialogs/
│   │   │   ├── confirmation_dialog.dart
│   │   │   ├── input_dialog.dart
│   │   │   └── export_format_dialog.dart
│   │   │
│   │   └── layouts/
│   │       ├── responsive_layout.dart
│   │       └── scrollable_content.dart
│   │
│   ├── utils/
│   │   ├── constants.dart               # App constants
│   │   ├── validators.dart              # Input validators
│   │   ├── formatters.dart              # Data formatters
│   │   └── extensions.dart              # Dart extensions
│   │
│   └── errors/
│       ├── exceptions.dart              # Custom exceptions
│       └── error_handler.dart           # Error handling
│
├── features/                            # Feature modules (each sport/feature is a module)
│   │
│   ├── sports/                          # Sports module (parent)
│   │   ├── models/
│   │   │   ├── sport_player.dart       # Extends base_player
│   │   │   ├── sport_match.dart        # Match model
│   │   │   └── sport_stat.dart         # Extends base_stat
│   │   │
│   │   ├── services/
│   │   │   ├── match_service.dart      # Match CRUD operations
│   │   │   └── stat_calculator.dart    # Stat calculations
│   │   │
│   │   ├── widgets/
│   │   │   ├── stat_counter.dart       # Reusable stat counter
│   │   │   ├── player_list.dart        # Reusable player list
│   │   │   └── half_selector.dart      # First/Second half selector
│   │   │
│   │   ├── soccer/                     # Soccer module
│   │   │   ├── models/
│   │   │   │   └── soccer_player.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── soccer_match_screen.dart
│   │   │   │   └── soccer_settings_screen.dart
│   │   │   │
│   │   │   ├── widgets/
│   │   │   │   └── soccer_specific_widgets.dart
│   │   │   │
│   │   │   └── soccer_config.dart      # Soccer-specific config
│   │   │
│   │   ├── basketball/                 # Basketball module
│   │   │   ├── models/
│   │   │   │   └── basketball_player.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── basketball_match_screen.dart
│   │   │   │   └── basketball_settings_screen.dart
│   │   │   │
│   │   │   └── basketball_config.dart
│   │   │
│   │   └── shared/                     # Shared sports screens
│   │       ├── screens/
│   │       │   ├── saved_matches_screen.dart
│   │       │   └── match_sheet_screen.dart
│   │       │
│   │       └── widgets/
│   │           └── match_card.dart
│   │
│   ├── training/                       # Training module
│   │   ├── models/
│   │   │   ├── training_player.dart
│   │   │   ├── training_session.dart
│   │   │   └── exercise.dart
│   │   │
│   │   ├── services/
│   │   │   ├── training_service.dart
│   │   │   └── exercise_service.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── player_selection_screen.dart
│   │   │   ├── training_type_screen.dart
│   │   │   └── player_stats_screen.dart
│   │   │
│   │   ├── strength/                   # Strength & Condition sub-module
│   │   │   ├── models/
│   │   │   │   └── strength_exercise.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── strength_screen.dart
│   │   │   │   ├── exercise_setup_screen.dart
│   │   │   │   ├── saved_sessions_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       └── exercise_card.dart
│   │   │
│   │   ├── technical/                  # Technical Performance sub-module
│   │   │   ├── models/
│   │   │   │   └── technical_skill.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── technical_screen.dart
│   │   │   │   ├── skill_setup_screen.dart
│   │   │   │   ├── saved_sessions_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       └── skill_card.dart
│   │   │
│   │   └── widgets/
│   │       └── training_card.dart
│   │
│   └── home/                           # Home/Dashboard module
│       ├── screens/
│       │   └── home_screen.dart
│       │
│       └── widgets/
│           └── sport_card.dart
│
└── config/
    ├── app_config.dart                 # App configuration
    └── environment.dart                # Environment variables
```

---

## 🏗️ Architecture Patterns

### 1. **Feature-Based Architecture**
Each sport/feature is a self-contained module with its own:
- Models
- Services
- Screens
- Widgets

### 2. **Repository Pattern**
```dart
// Abstract interface
abstract class StorageRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
}

// Implementation
class PlayerRepository implements StorageRepository<Player> {
  // Implementation details
}
```

### 3. **Service Layer**
Separate business logic from UI:
```dart
class MatchService {
  final StorageRepository<Match> _repository;
  
  Future<void> saveMatch(Match match) async {
    // Business logic here
    await _repository.save(match);
  }
}
```

### 4. **Strategy Pattern for Export**
```dart
abstract class ExportStrategy {
  Future<List<int>> export(dynamic data);
}

class TxtExportStrategy implements ExportStrategy { }
class ExcelExportStrategy implements ExportStrategy { }

class ExportService {
  Future<void> export(dynamic data, ExportStrategy strategy) {
    return strategy.export(data);
  }
}
```

---

## 🔧 Implementation Steps

### Phase 1: Core Infrastructure (Week 1)
1. Create core folder structure
2. Extract common models to `core/models/`
3. Create abstract service interfaces
4. Move shared widgets to `core/widgets/`

### Phase 2: Refactor Storage (Week 1-2)
1. Create `StorageRepository` interface
2. Implement repository for each entity type
3. Refactor existing `StorageService` to use repositories
4. Add unit tests for repositories

### Phase 3: Refactor Export (Week 2)
1. Create `ExportStrategy` interface
2. Implement `TxtExportStrategy`
3. Implement `ExcelExportStrategy`
4. Refactor screens to use new export service

### Phase 4: Modularize Sports (Week 3)
1. Create `features/sports/` structure
2. Extract common sports logic to parent
3. Move soccer to `features/sports/soccer/`
4. Move basketball to `features/sports/basketball/`
5. Create shared sports widgets

### Phase 5: Modularize Training (Week 3-4)
1. Create `features/training/` structure
2. Move strength module
3. Move technical module
4. Extract common training logic

### Phase 6: Testing & Documentation (Week 4)
1. Add unit tests for services
2. Add widget tests
3. Update documentation
4. Create developer guide

---

## 📝 Coding Standards

### File Naming
- `snake_case.dart` for files
- `PascalCase` for classes
- `camelCase` for variables/functions

### Folder Organization
```
feature_name/
├── models/          # Data models
├── services/        # Business logic
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── feature_config.dart  # Feature configuration
```

### Import Organization
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:shared_preferences/shared_preferences.dart';

// 4. Relative imports (grouped by layer)
import '../../core/models/base_player.dart';
import '../services/match_service.dart';
import '../widgets/stat_counter.dart';
```

---

## 🎨 Benefits of This Architecture

### ✅ Maintainability
- Clear separation of concerns
- Easy to find and fix bugs
- Consistent code structure

### ✅ Scalability
- Add new sports by copying a module template
- Add new features without touching existing code
- Easy to add new export formats

### ✅ Reusability
- Shared widgets across all modules
- Common services for all features
- Base models reduce duplication

### ✅ Testability
- Services can be tested independently
- Mock repositories for testing
- Widget tests for UI components

---

## 🚀 Adding a New Sport (Example: Volleyball)

1. **Create module structure**:
```
features/sports/volleyball/
├── models/
│   └── volleyball_player.dart
├── screens/
│   ├── volleyball_match_screen.dart
│   └── volleyball_settings_screen.dart
├── widgets/
│   └── volleyball_specific_widgets.dart
└── volleyball_config.dart
```

2. **Define configuration**:
```dart
// volleyball_config.dart
class VolleyballConfig {
  static List<StatType> getDefaultStats() {
    return [
      StatType(key: 'serves', label: 'Serves'),
      StatType(key: 'spikes', label: 'Spikes'),
      StatType(key: 'blocks', label: 'Blocks'),
      // ...
    ];
  }
}
```

3. **Create screen** (reuse sports widgets):
```dart
class VolleyballMatchScreen extends StatefulWidget {
  // Use shared sports widgets
  // Add volleyball-specific logic
}
```

4. **Register in routes**:
```dart
// app/routes.dart
'/volleyball': (context) => VolleyballMatchScreen(),
```

5. **Add to home screen**:
```dart
// Just add to sports list
SportCard(
  title: 'Volleyball',
  icon: Icons.sports_volleyball,
  route: '/volleyball',
)
```

**Time to add new sport: ~2-3 hours** (vs current: ~1-2 days)

---

## 📊 Migration Strategy

### Option A: Big Bang (Not Recommended)
- Refactor everything at once
- High risk, long downtime
- Hard to test incrementally

### Option B: Strangler Fig Pattern (Recommended)
- Gradually replace old code with new
- Keep app working during migration
- Test each module independently

**Recommended Approach**:
1. Create new structure alongside old
2. Move one feature at a time
3. Test thoroughly after each move
4. Remove old code when confident
5. Repeat for next feature

---

## 🛠️ Tools & Best Practices

### State Management
Consider adding:
- **Provider** (simple, good for small apps)
- **Riverpod** (more robust, better testing)
- **Bloc** (complex but scalable)

### Code Generation
- **freezed**: Immutable models
- **json_serializable**: JSON serialization
- **build_runner**: Code generation

### Testing
```
test/
├── unit/           # Service tests
├── widget/         # Widget tests
└── integration/    # E2E tests
```

### Documentation
- Add README.md to each feature
- Document public APIs
- Add code examples

---

## 📈 Success Metrics

After refactoring, you should see:
- ✅ 50% reduction in code duplication
- ✅ 70% faster to add new features
- ✅ 80% easier to find and fix bugs
- ✅ 90% better code organization
- ✅ 100% more confidence in changes

---

## 🎯 Next Steps

1. **Review this plan** with your team
2. **Choose migration strategy** (Strangler Fig recommended)
3. **Start with Phase 1** (Core Infrastructure)
4. **Set up testing framework**
5. **Begin migration** one module at a time

---

## 📚 Additional Resources

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First Organization](https://codewithandrea.com/articles/flutter-project-structure/)

---

**Questions? Need help with implementation? Let me know!**
