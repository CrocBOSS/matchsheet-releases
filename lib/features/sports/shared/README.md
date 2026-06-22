# Shared Sports Module

## Overview
This module contains shared functionality used by all sports modules (Soccer, Basketball, etc.).

## Structure

```
shared/
├── screens/
│   ├── saved_matches_screen.dart   # View and manage saved matches
│   └── match_sheet_screen.dart     # Display match sheet summary
└── README.md                       # This file
```

## Files

### screens/saved_matches_screen.dart
Screen for viewing and managing saved matches:
- List all saved matches for a specific sport
- Load a saved match
- Delete saved matches
- Export saved matches (TXT and Excel)
- View match details

**Features:**
- Sport-specific filtering (soccer, basketball)
- Match preview with player count and date
- Export functionality
- Delete with confirmation
- Load match callback for parent screen

### screens/match_sheet_screen.dart
Screen for displaying match sheet summary:
- Display all players and their stats
- Show team name
- Scrollable view for large rosters
- Read-only view of match data

**Features:**
- Player list with numbers and names
- Stat display for each player
- Team name header
- Responsive layout

## Usage

### Importing
```dart
// Import saved matches screen
import 'package:matchsheet/features/sports/shared/screens/saved_matches_screen.dart';

// Import match sheet screen
import 'package:matchsheet/features/sports/shared/screens/match_sheet_screen.dart';
```

### Using Saved Matches Screen
```dart
// Navigate to saved matches
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SavedMatchesScreen(
      sport: 'soccer', // or 'basketball'
      onLoadMatch: (sessionData) {
        // Handle loading the match
        _loadGameSession(sessionData);
      },
    ),
  ),
);
```

### Using Match Sheet Screen
```dart
// Navigate to match sheet
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MatchSheetScreen(
      players: players,
      statTypes: statTypes,
      teamName: teamName,
    ),
  ),
);
```

## Dependencies

### Internal
- `models/match_entry.dart` - Player model
- `models/stat_type.dart` - Stat type model
- `services/storage_service.dart` - Data persistence
- `core/services/export/` - Export functionality

### External
- `flutter/material.dart` - UI framework

## Used By

### Soccer Module
- `lib/features/sports/soccer/screens/soccer_screen.dart`
  - Uses `SavedMatchesScreen` to load saved soccer matches

### Basketball Module
- `lib/features/sports/basketball/screens/basketball_screen.dart`
  - Uses `SavedMatchesScreen` to load saved basketball matches

## Future Enhancements

### Planned
- [ ] Extract common sports models (sport_player, sport_session)
- [ ] Create common sports services (match_service, stat_calculator)
- [ ] Add shared sports widgets (stat_counter, player_list, half_selector)
- [ ] Add unit tests
- [ ] Add widget tests

### Possible
- [ ] Add match comparison feature
- [ ] Add match statistics dashboard
- [ ] Add match search and filtering
- [ ] Add match sorting options
- [ ] Add bulk operations (export multiple, delete multiple)

## Migration Notes

### Phase 3C (Current)
- ✅ Moved `saved_matches_screen.dart` from `lib/screens/shared/` to `lib/features/sports/shared/screens/`
- ✅ Moved `match_sheet_screen.dart` from `lib/screens/shared/` to `lib/features/sports/shared/screens/`
- ✅ Updated imports in soccer and basketball modules
- ✅ Verified compilation (no errors)

### Backward Compatibility
- Uses existing `Player` model
- Uses existing `StorageService` for data persistence
- Uses existing export functionality
- All saved matches load correctly
- No breaking changes to user experience

## Testing

### Manual Testing Checklist
- [ ] Open saved matches from soccer screen
- [ ] Open saved matches from basketball screen
- [ ] Load a saved soccer match
- [ ] Load a saved basketball match
- [ ] Delete a saved match
- [ ] Export a saved match (TXT)
- [ ] Export a saved match (Excel)
- [ ] View match sheet from saved matches
- [ ] Verify sport filtering works

### Automated Testing
- [ ] Unit tests for saved matches screen logic
- [ ] Widget tests for saved matches screen
- [ ] Widget tests for match sheet screen
- [ ] Integration tests for load/delete/export workflows

## Support

For issues or questions about the shared sports module, refer to:
- `ARCHITECTURE.md` - Overall architecture
- `PHASE3_MODULARIZATION_SPEC.md` - Modularization plan
- `REFACTORING_GUIDE.md` - Refactoring guide
