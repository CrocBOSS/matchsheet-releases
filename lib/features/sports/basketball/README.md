# Basketball Module

## Overview
This module contains all basketball-specific functionality for the Match Sheet app.

## Structure

```
basketball/
├── models/
│   └── basketball_player.dart      # Basketball player model (type alias + extensions)
├── screens/
│   ├── basketball_screen.dart      # Main basketball match screen
│   └── settings_screen.dart        # Basketball settings (stat types, positions)
├── basketball_config.dart          # Basketball configuration (defaults)
└── README.md                       # This file
```

## Files

### basketball_config.dart
Contains basketball-specific configuration:
- Default stat types (points, assists, rebounds, etc.)
- Default positions (PG, SG, SF, PF, C, etc.)
- Sport identifier and display name

### models/basketball_player.dart
- Type alias for `Player` model (maintains backward compatibility)
- Extension methods for basketball-specific functionality:
  - Position checks (isGuard, isForward, isCenter)
  - Stat totals (totalPoints, totalAssists, totalRebounds, etc.)
  - Calculated stats (pointsPerGame, fieldGoalPercentage)

### screens/basketball_screen.dart
Main basketball match screen with:
- Player management (add, edit, remove)
- Stat tracking (first half, second half)
- Match session management (save, load, export)
- Team name management
- Import players from file

### screens/settings_screen.dart
Basketball settings screen with:
- Stat type management (add, edit, remove, reset)
- Position management (add, edit, remove, reset)
- Tabbed interface for easy navigation

## Usage

### Importing
```dart
// Import basketball screen
import 'package:matchsheet/features/sports/basketball/screens/basketball_screen.dart';

// Import basketball config
import 'package:matchsheet/features/sports/basketball/basketball_config.dart';

// Import basketball player model
import 'package:matchsheet/features/sports/basketball/models/basketball_player.dart';
```

### Navigation
```dart
// Navigate to basketball screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const BasketballScreen()),
);
```

### Using Basketball Config
```dart
// Get default stat types
final statTypes = BasketballConfig.getDefaultStatTypes();

// Get default positions
final positions = BasketballConfig.getDefaultPositions();

// Get sport identifier
final sportId = BasketballConfig.sportId; // 'basketball'
```

### Using Basketball Player Extensions
```dart
final player = BasketballPlayer(/* ... */);

// Check position
if (player.isGuard) {
  print('This is a guard');
}

// Get totals
print('Total points: ${player.totalPoints}');
print('Total rebounds: ${player.totalRebounds}');
print('Total assists: ${player.totalAssists}');

// Calculate stats
print('PPG: ${player.pointsPerGame(10)}'); // 10 games played
```

## Data Storage

### Player Data
- First half stats stored in `Player.customStats` map
- Second half stats stored in `Player.secondHalfStats` map
- Individual stat fields (points, assists, etc.) are always 0
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
- [ ] Create basketball-specific service layer
- [ ] Add basketball-specific widgets
- [ ] Add unit tests
- [ ] Add widget tests

### Possible
- [ ] Add shot chart tracking
- [ ] Add play-by-play timeline
- [ ] Add advanced statistics (PER, TS%, etc.)
- [ ] Add lineup management
- [ ] Add substitution tracking

## Migration Notes

### Phase 3B (Current)
- ✅ Created basketball module structure
- ✅ Moved screens from `lib/screens/basketball/` to `lib/features/sports/basketball/screens/`
- ✅ Created `basketball_config.dart` with defaults
- ✅ Created `basketball_player.dart` model
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
- [ ] Open basketball screen from home
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
- [ ] Unit tests for BasketballConfig
- [ ] Unit tests for BasketballPlayer extensions
- [ ] Widget tests for basketball_screen
- [ ] Widget tests for settings_screen
- [ ] Integration tests for full workflow

## Support

For issues or questions about the basketball module, refer to:
- `ARCHITECTURE.md` - Overall architecture
- `PHASE3_MODULARIZATION_SPEC.md` - Modularization plan
- `REFACTORING_GUIDE.md` - Refactoring guide
