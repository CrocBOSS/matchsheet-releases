# Codebase Analysis - Current State

## 📊 Current Structure Overview

### Directory Structure
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── match_entry.dart        # Player model for sports
│   ├── stat_type.dart          # Stat type definition
│   ├── training_entry.dart     # Training session entry
│   ├── training_player.dart    # Training player model
│   └── technical_skill.dart    # Technical skill model
├── screens/                     # UI screens
│   ├── basketball/             # Basketball module
│   ├── soccer/                 # Soccer module
│   ├── shared/                 # Shared screens (home, saved matches)
│   └── training/               # Training module
├── services/                    # Business logic & data
│   ├── storage_service.dart    # Main storage service (SharedPreferences)
│   ├── document_service.dart   # Document handling
│   └── exercise_config_service.dart  # Exercise configuration
├── utils/                       # Utilities
│   └── dialog_helpers.dart     # Reusable dialogs
└── widgets/                     # Reusable widgets
    ├── player_list_panel.dart  # Player list UI
    ├── stat_counter_box.dart   # Stat counter UI
    └── stats_grid_panel.dart   # Stats grid UI
```

## 🔍 Key Findings

### 1. Data Models

#### Player Model (`match_entry.dart`)
- **Purpose**: Represents a player in sports modules (soccer, basketball)
- **Key Fields**:
  - Basic info: id, number, name, teamName, position
  - Individual stat fields: completedPasses, interceptions, etc. (always 0)
  - `customStats` map: Stores FIRST HALF stats
  - `secondHalfStats` map: Stores SECOND HALF stats
  - comments, rating
- **Important**: First half stats stored in `customStats`, second half in `secondHalfStats`
- **Serialization**: `toJson()` merges customStats into main JSON, `fromJson()` extracts all integer fields into customStats

#### TrainingPlayer Model (`training_player.dart`)
- **Purpose**: Represents a player in training module
- **Key Fields**: id (UUID), name, number, position, createdDate
- **Simpler**: No stats stored in player model itself

#### StatType Model (`stat_type.dart`)
- **Purpose**: Defines a stat type (key + label)
- **Usage**: Configurable stat types for different sports

### 2. Storage Service (`storage_service.dart`)

**Massive monolithic service** (~1977 lines) that handles:

#### Sports Data Storage
- `savePlayers()` / `loadPlayers()` - Player CRUD
- `saveGameSession()` / `loadSavedSessions()` - Match sessions
- `saveStatTypes()` / `loadStatTypes()` - Stat type configuration
- `savePositions()` / `loadPositions()` - Position configuration
- Default stat types for Soccer and Basketball
- Default positions for Soccer and Basketball

#### Training Data Storage
- `saveTrainingEntries()` / `loadTrainingEntries()` - Training session CRUD
- `clearTrainingData()` - Clear training data
- Default strength exercises
- Default technical skills
- `saveStrengthExercises()` / `loadStrengthExercises()`
- `saveTechnicalSkills()` / `loadTechnicalSkills()`

#### Export Functionality
- `generateMatchSheetText()` - Generate TXT export for sports
- `generateMatchSheetExcel()` - Generate Excel export for sports
- `generateTrainingDataExport()` - Generate TXT export for training
- `generateTrainingDataExcel()` - Generate Excel export for training
- Helper methods: `_getFirstHalfStatValue()`, `_calculateFirstHalfStatTotal()`, etc.

#### Utility Methods
- `parsePlayersFromText()` - Parse player list from text
- `parseSessionData()` - Parse session JSON
- Unsaved match handling
- Session management

**Issues**:
- Single responsibility principle violated (does everything)
- Hard to test individual components
- Difficult to extend with new features
- Export logic mixed with storage logic
- No separation between sports and training logic

### 3. Screens Organization

#### Shared Screens (`screens/shared/`)
- `home_screen.dart` - Main menu (Soccer, Basketball, Training)
- `saved_matches_screen.dart` - View saved matches
- `match_sheet_screen.dart` - Display match sheet

#### Soccer Module (`screens/soccer/`)
- Soccer-specific screens and logic
- Uses Player model with customStats/secondHalfStats

#### Basketball Module (`screens/basketball/`)
- Basketball-specific screens and logic
- Uses same Player model as soccer

#### Training Module (`screens/training/`)
- Training player selection
- Strength & Condition screens
- Technical Performance screens
- Uses TrainingPlayer and TrainingEntry models

### 4. Reusable Widgets

#### StatCounterBox (`widgets/stat_counter_box.dart`)
- **Purpose**: Display and increment/decrement stats
- **Usage**: Used in all sports modules
- **Good candidate**: Move to `core/widgets/`

#### PlayerListPanel (`widgets/player_list_panel.dart`)
- **Purpose**: Display list of players with selection
- **Usage**: Used in sports modules
- **Good candidate**: Move to `core/widgets/`

#### DialogHelpers (`utils/dialog_helpers.dart`)
- **Purpose**: Reusable dialogs (text input, rating)
- **Usage**: Used across all modules
- **Good candidate**: Move to `core/utils/`

## 🎯 Phase 1 Implementation Plan

Based on the analysis, here's what we'll do in Phase 1:

### Step 1: Create Core Folder Structure ✅
```
lib/core/
├── models/
├── services/
│   ├── storage/
│   ├── export/
│   └── share/
├── widgets/
│   ├── buttons/
│   ├── cards/
│   ├── dialogs/
│   └── layouts/
└── utils/
```

### Step 2: Extract Base Models
- Create `base_player.dart` - Abstract base for all players
- Create `base_stat.dart` - Base stat model
- Keep existing models, gradually migrate to extend base models

### Step 3: Create Repository Interfaces
- Create `storage_repository.dart` - Generic CRUD interface
- Create `local_storage_repository.dart` - SharedPreferences implementation
- Don't touch existing StorageService yet (Strangler Fig pattern)

### Step 4: Create Export Service
- Create `export_strategy.dart` - Strategy interface
- Create `txt_export_strategy.dart` - Text export implementation
- Create `excel_export_strategy.dart` - Excel export implementation
- Create `export_service.dart` - Main export service
- Gradually migrate export logic from StorageService

### Step 5: Move Common Widgets
- Move `StatCounterBox` to `core/widgets/cards/`
- Move `PlayerListPanel` to `core/widgets/layouts/`
- Move `DialogHelpers` to `core/utils/`
- Create `ExportFormatDialog` in `core/widgets/dialogs/`
- Update imports in existing screens

### Step 6: Test Everything
- Run app after each change
- Verify all features still work
- No breaking changes

## 🚨 Critical Considerations

### Data Storage Pattern
- **First Half Stats**: Stored in `Player.customStats` map
- **Second Half Stats**: Stored in `Player.secondHalfStats` map
- **Individual Fields**: Always 0, actual values in maps
- **Must preserve this pattern** during refactoring

### Export Logic
- Text and Excel formats supported
- Must export First Half, Second Half, and Full Match data
- Training exports support selective export (S&C only, Technical only, or both)
- Format selection dialog shown before export

### Backward Compatibility
- Must maintain SharedPreferences keys
- Must maintain JSON structure for saved data
- Cannot break existing saved matches/training sessions

### Testing Strategy
- Test after each file move
- Verify imports are updated
- Run app and test each module
- Check export functionality
- Verify data persistence

## 📝 Next Steps

1. ✅ Create core folder structure
2. ✅ Create base models
3. ✅ Create repository interfaces
4. ✅ Create export service interfaces
5. ✅ Move common widgets
6. Test thoroughly
7. Document changes
8. Commit

---

**Status**: Ready to begin Phase 1 implementation
**Approach**: Strangler Fig Pattern (new alongside old, gradual migration)
**Risk Level**: Low (additive changes, no breaking modifications)
