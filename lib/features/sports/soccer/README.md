# Soccer Module

## Overview
This module contains all soccer-specific functionality for the Match Sheet app.

## Structure

```
soccer/
├── models/
│   └── soccer_player.dart          # Soccer player model (type alias + extensions)
├── screens/
│   ├── soccer_screen.dart          # Main soccer match screen
│   └── settings_screen.dart        # Soccer settings (stat types, positions)
├── soccer_config.dart              # Soccer configuration (defaults)
└── README.md                       # This file
```

## Files

### soccer_config.dart
Contains soccer-specific configuration:
- Default stat types (goals, assists, tackles, etc.)
- Default positions (GK, CB, ST, etc.)
- Sport identifier and display name

### models/soccer_player.dart
- Type alias for `Player` model (maintains backward compatibility)
- Extension methods for soccer-specific functionality:
  - Position checks (isGoalkeeper, isDefender, etc.)
  - Stat totals (totalGoals, totalAssists, etc.)

### screens/soccer_screen.dart
Main soccer match screen with:
- Player management (add, edit, remove)
- Stat tracking (first half, second half)
- Match session management (save, load, export)
- Team name management
- Import players from file

### screens/settings_screen.dart
Soccer settings screen with:
- Stat type management (add, edit, remove, reset)
- Position management (add, edit, remove, reset)
- Tabbed interface for easy navigation

## Usage

### Importing
```dart
// Import soccer screen
import 'package:matchsheet/features/sports/soccer/screens/soccer_screen.dart';

// Import soccer config
import 'package:matchsheet/features/sports/soccer/soccer_config.dart';

// Import soccer player model
import 'package:matchsheet/features/sports/soccer/models/soccer_player.dart';
```

### Navigation
```dart
// Navigate to soccer screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SoccerScreen()),
);
```

### Using Soccer Config
```dart
// Get default stat types
final statTypes = SoccerConfig.getDefaultStatTypes();

// Get default positions
final positions = SoccerConfig.getDefaultPositions();

// Get sport identifier
final sportId = SoccerConfig.sportId; // 'soccer'
```

### Using Soccer Player Extensions
```dart
final player = SoccerPlayer(/* ... */);

// Check position
if (player.isGoalkeeper) {
  print('This is a goalkeeper');
}

// Get totals
print('Total goals: ${player.totalGoals}');
print('Total assists: ${player.totalAssists}');
```

## Data Storage

### Player Data
- First half stats stored in `Player.customStats` map
- Second half stats stored in `Player.secondHalfStats` map
- Individual stat fields (goals, assists, etc.) are always 0
- Actual values are in the maps

### Session Data
- Saved to SharedPreferences via `StorageService`
- Session includes: players, stat types, team name, sport identifier
- Unsaved matches are auto-saved for recovery

## Dependencies

### Internal
- `models/match_entry.dart` - Player model
- `models/stat_type.dart` - Stat type model
- `services/storage_service.dart` - Data persistence
- `core/services/export/` - Export functionality
- `core/widgets/dialogs/` - Reusable dialogs

### External
- `flutter/material.dart` - UI framework
- `file_picker` - File import functionality

## Future Enhancements

### Planned
- [ ] Extract common sports logic to shared module
- [ ] Create soccer-specific service layer
- [ ] Add soccer-specific widgets
- [ ] Add unit tests
- [ ] Add widget tests

### Possible
- [ ] Add formation management
- [ ] Add substitution tracking
- [ ] Add match timeline
- [ ] Add heat maps
- [ ] Add advanced statistics

## Migration Notes

### Phase 3A (Current)
- ✅ Created soccer module structure
- ✅ Moved screens from `lib/screens/soccer/` to `lib/features/sports/soccer/screens/`
- ✅ Created `soccer_config.dart` with defaults
- ✅ Created `soccer_player.dart` model
- ✅ Updated all imports
- ✅ Verified compilation (no errors)

### Backward Compatibility
- Uses existing `Player` model (type alias)
- Uses existing `StorageService` for data persistence
- Uses existing export functionality
- All saved matches load correctly
- No breaking changes to user experience

## Testing

### Manual Testing Checklist
- [ ] Open soccer screen from home
- [ ] Add new player
- [ ] Edit player details
- [ ] Increment/decrement stats
- [ ] Switch between first/second half
- [ ] Save match with name
- [ ] Load saved match
- [ ] Export match (TXT and Excel)
- [ ] Import players from file
- [ ] Edit team name
- [ ] Open settings
- [ ] Add/edit/remove stat types
- [ ] Add/edit/remove positions
- [ ] Reset to defaults

### Automated Testing
- [ ] Unit tests for SoccerConfig
- [ ] Unit tests for SoccerPlayer extensions
- [ ] Widget tests for soccer_screen
- [ ] Widget tests for settings_screen
- [ ] Integration tests for full workflow

## Support

For issues or questions about the soccer module, refer to:
- `ARCHITECTURE.md` - Overall architecture
- `PHASE3_MODULARIZATION_SPEC.md` - Modularization plan
- `REFACTORING_GUIDE.md` - Refactoring guide
