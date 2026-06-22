# Phase 3: Module Modularization Spec

## 🎯 Overview

This spec defines the work required to modularize the Soccer, Basketball, and Training modules into the feature-based architecture defined in ARCHITECTURE.md. This phase will move existing code into proper feature modules while maintaining backward compatibility.

---

## 📋 Scope

### In Scope
- ✅ Modularize Soccer module → `lib/features/sports/soccer/`
- ✅ Modularize Basketball module → `lib/features/sports/basketball/`
- ✅ Modularize Training module → `lib/features/training/`
- ✅ Extract common sports logic → `lib/features/sports/shared/`
- ✅ Update all imports and references
- ✅ Maintain 100% backward compatibility

### Out of Scope
- ❌ Changing existing functionality or behavior
- ❌ Adding new features
- ❌ Modifying data storage format
- ❌ UI/UX changes

---

## 🏗️ Target Architecture

### Final Folder Structure

```
lib/
├── core/                                    # ✅ Already exists (Phase 1)
│   ├── models/
│   ├── services/
│   ├── widgets/
│   └── utils/
│
├── features/                                # 🆕 NEW in Phase 3
│   ├── sports/                              # Sports parent module
│   │   ├── models/                          # Shared sports models
│   │   │   ├── sport_player.dart           # Extends base_player
│   │   │   └── sport_session.dart          # Match session model
│   │   │
│   │   ├── services/                        # Shared sports services
│   │   │   ├── match_service.dart          # Common match operations
│   │   │   └── stat_calculator.dart        # Stat calculations
│   │   │
│   │   ├── widgets/                         # Shared sports widgets
│   │   │   ├── stat_counter.dart           # Reusable stat counter
│   │   │   ├── player_list.dart            # Reusable player list
│   │   │   └── half_selector.dart          # First/Second half selector
│   │   │
│   │   ├── soccer/                          # Soccer-specific module
│   │   │   ├── models/
│   │   │   │   └── soccer_player.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── soccer_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   │
│   │   │   └── soccer_config.dart          # Soccer configuration
│   │   │
│   │   ├── basketball/                      # Basketball-specific module
│   │   │   ├── models/
│   │   │   │   └── basketball_player.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── basketball_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   │
│   │   │   └── basketball_config.dart      # Basketball configuration
│   │   │
│   │   └── shared/                          # Shared sports screens
│   │       └── screens/
│   │           ├── saved_matches_screen.dart
│   │           └── match_sheet_screen.dart
│   │
│   ├── training/                            # Training module
│   │   ├── models/
│   │   │   ├── training_player.dart
│   │   │   ├── training_entry.dart
│   │   │   └── exercise.dart
│   │   │
│   │   ├── services/
│   │   │   ├── training_service.dart
│   │   │   └── exercise_service.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── training_screen.dart
│   │   │   ├── player_selection_screen.dart
│   │   │   └── player_stats_screen.dart
│   │   │
│   │   ├── strength/                        # Strength & Condition sub-module
│   │   │   ├── models/
│   │   │   │   └── strength_exercise.dart
│   │   │   │
│   │   │   └── screens/
│   │   │       ├── strength_screen.dart
│   │   │       ├── exercise_setup_screen.dart
│   │   │       ├── saved_sessions_screen.dart
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── technical/                       # Technical Performance sub-module
│   │       ├── models/
│   │       │   └── technical_skill.dart
│   │       │
│   │       └── screens/
│   │           ├── technical_screen.dart
│   │           ├── skill_setup_screen.dart
│   │           ├── saved_sessions_screen.dart
│   │           └── settings_screen.dart
│   │
│   └── home/                                # Home/Dashboard module
│       └── screens/
│           └── home_screen.dart
│
├── models/                                  # ⚠️ OLD - Will be deprecated
├── screens/                                 # ⚠️ OLD - Will be deprecated
├── services/                                # ⚠️ OLD - Keep StorageService for now
└── widgets/                                 # ⚠️ OLD - Will be deprecated
```

---

## 📦 Module Breakdown

### Module 1: Soccer Module

#### Current Location
```
lib/screens/soccer/
├── soccer_screen.dart
└── settings_screen.dart

lib/models/
└── match_entry.dart (shared with basketball)
```

#### Target Location
```
lib/features/sports/soccer/
├── models/
│   └── soccer_player.dart
├── screens/
│   ├── soccer_screen.dart
│   └── settings_screen.dart
└── soccer_config.dart
```

#### Files to Create
1. `lib/features/sports/soccer/models/soccer_player.dart` - Soccer-specific player model
2. `lib/features/sports/soccer/soccer_config.dart` - Soccer configuration (stat types, positions)

#### Files to Move
1. `lib/screens/soccer/soccer_screen.dart` → `lib/features/sports/soccer/screens/soccer_screen.dart`
2. `lib/screens/soccer/settings_screen.dart` → `lib/features/sports/soccer/screens/settings_screen.dart`

---

### Module 2: Basketball Module

#### Current Location
```
lib/screens/basketball/
├── basketball_screen.dart
└── settings_screen.dart

lib/models/
└── match_entry.dart (shared with soccer)
```

#### Target Location
```
lib/features/sports/basketball/
├── models/
│   └── basketball_player.dart
├── screens/
│   ├── basketball_screen.dart
│   └── settings_screen.dart
└── basketball_config.dart
```

#### Files to Create
1. `lib/features/sports/basketball/models/basketball_player.dart` - Basketball-specific player model
2. `lib/features/sports/basketball/basketball_config.dart` - Basketball configuration

#### Files to Move
1. `lib/screens/basketball/basketball_screen.dart` → `lib/features/sports/basketball/screens/basketball_screen.dart`
2. `lib/screens/basketball/settings_screen.dart` → `lib/features/sports/basketball/screens/settings_screen.dart`

---

### Module 3: Training Module

#### Current Location
```
lib/screens/training/
├── training_screen.dart
├── player_selection_screen.dart
├── player_stats_screen.dart
├── strength_and_condition/
│   ├── strength_screen.dart
│   ├── exercise_setup_screen.dart
│   ├── saved_sessions_screen.dart
│   └── settings_screen.dart
└── technical_performance/
    ├── technical_screen.dart
    ├── skill_setup_screen.dart
    ├── saved_sessions_screen.dart
    └── settings_screen.dart

lib/models/
├── training_player.dart
├── training_entry.dart
└── technical_skill.dart
```

#### Target Location
```
lib/features/training/
├── models/
│   ├── training_player.dart
│   ├── training_entry.dart
│   └── exercise.dart
├── services/
│   ├── training_service.dart
│   └── exercise_service.dart
├── screens/
│   ├── training_screen.dart
│   ├── player_selection_screen.dart
│   └── player_stats_screen.dart
├── strength/
│   ├── models/
│   │   └── strength_exercise.dart
│   └── screens/
│       ├── strength_screen.dart
│       ├── exercise_setup_screen.dart
│       ├── saved_sessions_screen.dart
│       └── settings_screen.dart
└── technical/
    ├── models/
    │   └── technical_skill.dart
    └── screens/
        ├── technical_screen.dart
        ├── skill_setup_screen.dart
        ├── saved_sessions_screen.dart
        └── settings_screen.dart
```

#### Files to Move
1. Training models → `lib/features/training/models/`
2. Training screens → `lib/features/training/screens/`
3. Strength screens → `lib/features/training/strength/screens/`
4. Technical screens → `lib/features/training/technical/screens/`

#### Files to Create
1. `lib/features/training/services/training_service.dart` - Training business logic
2. `lib/features/training/services/exercise_service.dart` - Exercise management

---

### Module 4: Shared Sports Components

#### Files to Create
1. `lib/features/sports/models/sport_player.dart` - Base sports player model
2. `lib/features/sports/models/sport_session.dart` - Match session model
3. `lib/features/sports/services/match_service.dart` - Common match operations
4. `lib/features/sports/services/stat_calculator.dart` - Stat calculations
5. `lib/features/sports/widgets/stat_counter.dart` - Reusable stat counter
6. `lib/features/sports/widgets/player_list.dart` - Reusable player list
7. `lib/features/sports/widgets/half_selector.dart` - Half selector widget

#### Files to Move
1. `lib/screens/shared/saved_matches_screen.dart` → `lib/features/sports/shared/screens/saved_matches_screen.dart`
2. `lib/screens/shared/match_sheet_screen.dart` → `lib/features/sports/shared/screens/match_sheet_screen.dart`

---

### Module 5: Home Module

#### Files to Move
1. `lib/screens/shared/home_screen.dart` → `lib/features/home/screens/home_screen.dart`

---

## 🔄 Migration Strategy

### Phase 3A: Soccer Module (Week 1)
**Goal**: Modularize soccer module without breaking existing functionality

#### Step 1: Create Soccer Module Structure
- Create folder structure: `lib/features/sports/soccer/`
- Create `soccer_config.dart` with default stat types and positions
- Create `soccer_player.dart` model extending base player

#### Step 2: Move Soccer Screens
- Move `soccer_screen.dart` to new location
- Move `settings_screen.dart` to new location
- Update all imports in moved files

#### Step 3: Update References
- Update imports in `home_screen.dart`
- Update route definitions in `main.dart`
- Test soccer module thoroughly

#### Step 4: Verify & Test
- Run app and test all soccer features
- Verify data persistence works
- Verify export functionality works
- Check for any broken imports

---

### Phase 3B: Basketball Module (Week 1)
**Goal**: Modularize basketball module following soccer pattern

#### Step 1: Create Basketball Module Structure
- Create folder structure: `lib/features/sports/basketball/`
- Create `basketball_config.dart` with default stat types and positions
- Create `basketball_player.dart` model extending base player

#### Step 2: Move Basketball Screens
- Move `basketball_screen.dart` to new location
- Move `settings_screen.dart` to new location
- Update all imports in moved files

#### Step 3: Update References
- Update imports in `home_screen.dart`
- Update route definitions in `main.dart`
- Test basketball module thoroughly

#### Step 4: Verify & Test
- Run app and test all basketball features
- Verify data persistence works
- Verify export functionality works
- Check for any broken imports

---

### Phase 3C: Shared Sports Components (Week 2)
**Goal**: Extract common sports logic into shared module

#### Step 1: Create Shared Sports Structure
- Create folder structure: `lib/features/sports/shared/`
- Create `sport_player.dart` base model
- Create `sport_session.dart` model

#### Step 2: Create Shared Services
- Create `match_service.dart` with common match operations
- Create `stat_calculator.dart` with stat calculation logic
- Extract common logic from soccer/basketball screens

#### Step 3: Move Shared Screens
- Move `saved_matches_screen.dart` to shared location
- Move `match_sheet_screen.dart` to shared location
- Update all imports

#### Step 4: Refactor Soccer & Basketball
- Update soccer screens to use shared services
- Update basketball screens to use shared services
- Remove duplicate code

#### Step 5: Verify & Test
- Test both soccer and basketball modules
- Verify saved matches screen works
- Verify match sheet screen works

---

### Phase 3D: Training Module (Week 2-3)
**Goal**: Modularize training module with sub-modules

#### Step 1: Create Training Module Structure
- Create folder structure: `lib/features/training/`
- Create sub-folders for strength and technical
- Create training services

#### Step 2: Move Training Models
- Move `training_player.dart` to `lib/features/training/models/`
- Move `training_entry.dart` to `lib/features/training/models/`
- Move `technical_skill.dart` to `lib/features/training/technical/models/`

#### Step 3: Move Training Screens
- Move main training screens to `lib/features/training/screens/`
- Move strength screens to `lib/features/training/strength/screens/`
- Move technical screens to `lib/features/training/technical/screens/`
- Update all imports

#### Step 4: Create Training Services
- Create `training_service.dart` with training business logic
- Create `exercise_service.dart` with exercise management
- Extract logic from screens into services

#### Step 5: Update References
- Update imports in `home_screen.dart`
- Update route definitions in `main.dart`
- Test training module thoroughly

#### Step 6: Verify & Test
- Test all training features
- Test strength & condition module
- Test technical performance module
- Verify data persistence works
- Verify export functionality works

---

### Phase 3E: Home Module & Cleanup (Week 3)
**Goal**: Move home screen and clean up old structure

#### Step 1: Create Home Module
- Create folder structure: `lib/features/home/`
- Move `home_screen.dart` to new location
- Update imports and routes

#### Step 2: Update Main App
- Update `main.dart` with new routes
- Update navigation to use new module paths
- Test all navigation flows

#### Step 3: Deprecate Old Structure
- Add deprecation comments to old files
- Document migration path
- Keep old files for reference (don't delete yet)

#### Step 4: Final Verification
- Run full app test
- Test all modules (soccer, basketball, training)
- Test all navigation flows
- Test data persistence
- Test export functionality
- Verify no broken imports

#### Step 5: Documentation
- Update ARCHITECTURE.md with actual structure
- Create PHASE3_COMPLETE.md summary
- Document any issues encountered
- Create migration guide for future modules

---

## ✅ Acceptance Criteria

### Soccer Module
- [ ] Soccer screens moved to `lib/features/sports/soccer/screens/`
- [ ] Soccer models created in `lib/features/sports/soccer/models/`
- [ ] Soccer config created with default stat types and positions
- [ ] All imports updated correctly
- [ ] Soccer module fully functional (match creation, stats, export)
- [ ] Data persistence works (saved matches load correctly)
- [ ] No breaking changes to existing functionality

### Basketball Module
- [ ] Basketball screens moved to `lib/features/sports/basketball/screens/`
- [ ] Basketball models created in `lib/features/sports/basketball/models/`
- [ ] Basketball config created with default stat types and positions
- [ ] All imports updated correctly
- [ ] Basketball module fully functional (match creation, stats, export)
- [ ] Data persistence works (saved matches load correctly)
- [ ] No breaking changes to existing functionality

### Shared Sports Components
- [ ] Shared sports models created in `lib/features/sports/models/`
- [ ] Shared sports services created in `lib/features/sports/services/`
- [ ] Shared sports widgets created in `lib/features/sports/widgets/`
- [ ] Saved matches screen moved to `lib/features/sports/shared/screens/`
- [ ] Match sheet screen moved to `lib/features/sports/shared/screens/`
- [ ] Soccer and basketball use shared components
- [ ] No code duplication between soccer and basketball

### Training Module
- [ ] Training models moved to `lib/features/training/models/`
- [ ] Training screens moved to `lib/features/training/screens/`
- [ ] Strength screens moved to `lib/features/training/strength/screens/`
- [ ] Technical screens moved to `lib/features/training/technical/screens/`
- [ ] Training services created in `lib/features/training/services/`
- [ ] All imports updated correctly
- [ ] Training module fully functional (all sub-modules work)
- [ ] Data persistence works (training sessions load correctly)
- [ ] Export functionality works
- [ ] No breaking changes to existing functionality

### Home Module
- [ ] Home screen moved to `lib/features/home/screens/`
- [ ] All navigation updated to use new module paths
- [ ] All routes work correctly
- [ ] No broken links or navigation issues

### Overall
- [ ] All modules compile without errors
- [ ] All modules run without runtime errors
- [ ] All existing features work as before
- [ ] Data persistence maintained (old data loads correctly)
- [ ] Export functionality works for all modules
- [ ] No breaking changes to user experience
- [ ] Code is more organized and maintainable
- [ ] Documentation updated

---

## 🚨 Critical Considerations

### Data Compatibility
- **Must maintain SharedPreferences keys** - Don't change storage keys
- **Must maintain JSON structure** - Old saved data must load correctly
- **Must preserve data storage pattern** - First half stats in `customStats`, second half in `secondHalfStats`

### Import Updates
- **Update all imports** - Every moved file needs updated imports
- **Update route definitions** - Main.dart routes must point to new locations
- **Update navigation** - Home screen navigation must use new paths

### Testing Strategy
- **Test after each sub-phase** - Don't move to next module until current one works
- **Test data persistence** - Verify old saved data loads correctly
- **Test export functionality** - Verify TXT and Excel exports work
- **Test navigation** - Verify all navigation flows work

### Backward Compatibility
- **Keep old files temporarily** - Don't delete old structure until Phase 3 is complete
- **Add deprecation comments** - Mark old files as deprecated
- **Document migration** - Create clear migration guide

---

## 📊 Success Metrics

After Phase 3 completion:
- ✅ **0 breaking changes** - All existing features work
- ✅ **100% feature parity** - No functionality lost
- ✅ **Better organization** - Clear module boundaries
- ✅ **Reduced duplication** - Shared components extracted
- ✅ **Easier to extend** - Clear pattern for adding new sports
- ✅ **Maintainable** - Each module is self-contained

---

## 🎯 Next Steps After Phase 3

### Option A: Add New Sport
With the modular structure, adding a new sport (e.g., Volleyball) becomes easy:
1. Copy soccer module structure
2. Update configuration
3. Customize as needed
4. Add to home screen
**Estimated time: 2-3 hours** (vs current: 1-2 days)

### Option B: Add Testing
With separated modules, add unit tests:
1. Test services independently
2. Test widgets independently
3. Test screens with mocked services

### Option C: Add State Management
Consider adding Provider/Riverpod/Bloc for better state management

---

## 📝 Implementation Checklist

### Pre-Phase 3
- [ ] Review this spec
- [ ] Backup current codebase
- [ ] Create Phase 3 branch in git
- [ ] Ensure Phase 1 and Phase 2 are complete

### Phase 3A: Soccer Module
- [ ] Create soccer module structure
- [ ] Create soccer models
- [ ] Create soccer config
- [ ] Move soccer screens
- [ ] Update imports
- [ ] Update routes
- [ ] Test soccer module
- [ ] Commit changes

### Phase 3B: Basketball Module
- [ ] Create basketball module structure
- [ ] Create basketball models
- [ ] Create basketball config
- [ ] Move basketball screens
- [ ] Update imports
- [ ] Update routes
- [ ] Test basketball module
- [ ] Commit changes

### Phase 3C: Shared Sports Components
- [ ] Create shared sports structure
- [ ] Create shared models
- [ ] Create shared services
- [ ] Create shared widgets
- [ ] Move shared screens
- [ ] Refactor soccer to use shared components
- [ ] Refactor basketball to use shared components
- [ ] Test both modules
- [ ] Commit changes

### Phase 3D: Training Module
- [ ] Create training module structure
- [ ] Move training models
- [ ] Move training screens
- [ ] Move strength screens
- [ ] Move technical screens
- [ ] Create training services
- [ ] Update imports
- [ ] Update routes
- [ ] Test training module
- [ ] Commit changes

### Phase 3E: Home Module & Cleanup
- [ ] Create home module structure
- [ ] Move home screen
- [ ] Update all routes
- [ ] Test all navigation
- [ ] Add deprecation comments to old files
- [ ] Update documentation
- [ ] Create PHASE3_COMPLETE.md
- [ ] Final testing
- [ ] Commit changes

---

## 🎉 Conclusion

Phase 3 will transform the codebase from a flat structure to a modular, feature-based architecture. This will make the app:
- **Easier to maintain** - Clear module boundaries
- **Easier to extend** - Add new sports/features easily
- **Easier to test** - Test modules independently
- **More professional** - Industry-standard architecture

**Estimated Total Time**: 3-4 weeks (working incrementally)
**Risk Level**: 🟡 Medium (many file moves, but no logic changes)
**Reward**: 🟢 High (much better codebase organization)

---

**Status**: 📋 Spec Ready for Review
**Next Step**: Review and approve this spec, then begin Phase 3A (Soccer Module)
