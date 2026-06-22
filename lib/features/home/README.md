# Home Module

## Overview
This module contains the home screen - the main entry point of the application.

## Structure

```
home/
├── screens/
│   └── home_screen.dart    # Main home/dashboard screen
└── README.md               # This file
```

## Files

### screens/home_screen.dart
Main home screen with navigation to all features:
- Soccer module
- Basketball module
- Training module
- App settings

**Features:**
- Clean, card-based UI
- Direct navigation to each module
- App branding and title
- Exit confirmation dialog

## Usage

### Importing
```dart
// Import home screen
import 'package:matchsheet/features/home/screens/home_screen.dart';
```

### Navigation
```dart
// Set as initial route in main.dart
MaterialApp(
  home: const HomeScreen(),
  // ...
);
```

### Adding New Module
To add a new module to the home screen:

1. Add navigation card in home_screen.dart:
```dart
_buildModuleCard(
  context,
  'New Module',
  Icons.new_icon,
  Colors.purple,
  () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NewModuleScreen(),
    ),
  ),
),
```

2. Import the new module screen:
```dart
import '../../new_module/screens/new_module_screen.dart';
```

## Dependencies

### Internal
- `features/sports/soccer/screens/soccer_screen.dart` - Soccer module
- `features/sports/basketball/screens/basketball_screen.dart` - Basketball module
- `features/training/screens/training_player_selection_screen.dart` - Training module

### External
- `flutter/material.dart` - UI framework
- `flutter/services.dart` - System services (exit app)

## Navigation Flow

```
HomeScreen
├─→ SoccerScreen (Soccer module)
├─→ BasketballScreen (Basketball module)
└─→ TrainingPlayerSelectionScreen (Training module)
```

## Migration Notes

### Phase 3E (Current)
- ✅ Moved from `lib/screens/shared/home_screen.dart` to `lib/features/home/screens/home_screen.dart`
- ✅ Updated imports to use new feature paths
- ✅ Updated main.dart to import from new location
- ✅ Verified compilation (no errors)

### Backward Compatibility
- Uses existing module screens
- No changes to navigation logic
- No breaking changes to user experience

## Testing

### Manual Testing Checklist
- [ ] App launches and shows home screen
- [ ] Navigate to Soccer module
- [ ] Navigate to Basketball module
- [ ] Navigate to Training module
- [ ] Back button returns to home
- [ ] Exit confirmation dialog works
- [ ] All cards display correctly

### Automated Testing
- [ ] Widget tests for home screen
- [ ] Navigation tests for each module
- [ ] Exit dialog tests

## Support

For issues or questions about the home module, refer to:
- `ARCHITECTURE.md` - Overall architecture
- `PHASE3_MODULARIZATION_SPEC.md` - Modularization plan
- `PHASE3_COMPLETE_SUMMARY.md` - Complete summary
