# Tasks: Speed Skill Timer Enhancement

**Feature**: Speed Timer for Technical Performance Training  
**Status**: Ready for Implementation  
**Sprint**: 7 days estimated

---

## Task 1: Create SpeedAttempt Data Model ✅ COMPLETE
**Description**: Create the data model for storing individual speed attempt records

**Subtasks**:
- [x] 1.1: Create `lib/features/training/technical/models/speed_attempt.dart`
- [x] 1.2: Implement SpeedAttempt class with fields (attemptNumber, timeInMilliseconds, metTarget, timestamp)
- [x] 1.3: Add `formattedTime` getter method (returns MM:SS.mmm format)
- [x] 1.4: Add `getDifferenceFromTarget()` method
- [x] 1.5: Implement `toJson()` serialization method
- [x] 1.6: Implement `fromJson()` deserialization factory method
- [x] 1.7: Write unit tests for all methods

**Acceptance Criteria**:
- ✅ SpeedAttempt model compiles without errors
- ✅ All unit tests pass (20/20 tests passing)
- ✅ formattedTime correctly formats various durations
- ✅ JSON serialization/deserialization works correctly

**Dependencies**: None  
**Estimated**: 4 hours  
**Actual**: ~30 minutes

---

## Task 2: Add Storage Methods for Speed Sessions ✅ COMPLETE
**Description**: Extend StorageService with methods to save and load speed training sessions

**Subtasks**:
- [x] 2.1: Open `lib/services/storage_service.dart`
- [x] 2.2: Implement `saveSpeedTrainingSession()` static method
- [x] 2.3: Implement session data structure with all required fields
- [x] 2.4: Calculate and store stats (bestTime, averageTime, successRate)
- [x] 2.5: Implement `loadSpeedTrainingSessions()` static method (optional filtering by playerId)
- [x] 2.6: Test save/load with mock data
- [x] 2.7: Verify data persists in SharedPreferences

**Acceptance Criteria**:
- ✅ saveSpeedTrainingSession() saves data successfully
- ✅ Data persists after app restart (SharedPreferences)
- ✅ Statistics are calculated correctly (bestTime, averageTime, successRate)
- ✅ loadSpeedTrainingSessions() retrieves saved data
- ✅ Filtering by playerId works correctly
- ✅ Sessions sorted by date (newest first)
- ✅ All 10 unit tests passing

**Dependencies**: Task 1 (SpeedAttempt model)  
**Estimated**: 6 hours  
**Actual**: ~45 minutes

---

## Task 3: Create Speed Configuration Dialog ✅ COMPLETE
**Description**: Build custom configuration dialog for Speed skill with time and distance inputs

**Subtasks**:
- [x] 3.1: Create `lib/features/training/technical/widgets/speed_config_dialog.dart`
- [x] 3.2: Add target time TextField with numeric keyboard
- [x] 3.3: Add time unit DropdownButton (seconds default, minutes option)
- [x] 3.4: Add distance TextField with numeric keyboard
- [x] 3.5: Add distance unit DropdownButton (meters default, yards option)
- [x] 3.6: Implement validation (both values > 0)
- [x] 3.7: Add Cancel and Confirm buttons
- [x] 3.8: Return configuration data on Confirm
- [x] 3.9: Test dialog UI on different screen sizes
- [x] 3.10: Write comprehensive widget tests (17 tests, all passing)
- [x] 3.11: Fix deprecation warnings (changed value to initialValue)

**Acceptance Criteria**:
- ✅ Dialog displays correctly with all input fields
- ✅ Validation prevents invalid values
- ✅ Dropdowns show correct options with defaults
- ✅ Confirm returns structured configuration data
- ✅ Dialog matches existing app theme
- ✅ All 17 widget tests passing
- ✅ No deprecation warnings (only 2 const performance suggestions remain)

**Dependencies**: None  
**Estimated**: 4 hours  
**Actual**: ~45 minutes

---

## Task 4: Modify TechnicalSetupScreen for Speed Detection ✅ COMPLETE
**Description**: Update skill selection screen to detect Speed skill and show custom configuration

**Subtasks**:
- [x] 4.1: Open `lib/features/training/technical/screens/skill_setup_screen.dart`
- [x] 4.2: Import SpeedConfigDialog and SpeedTrainingScreen
- [x] 4.3: Add `_showSpeedConfigDialog()` method
- [x] 4.4: Modify `_selectSkillAndConfigure()` to detect `skill.key == 'speed'`
- [x] 4.5: Route Speed skill to SpeedConfigDialog instead of default dialog
- [x] 4.6: Store Speed config in state (targetTime, timeUnit, distance, distanceUnit)
- [x] 4.7: Update _startTraining() to check if Speed skill
- [x] 4.8: Navigate to SpeedTrainingScreen with config params for Speed (placeholder until Task 5)
- [x] 4.9: Add helper method to display Speed configuration in skill card

**Acceptance Criteria**:
- ✅ Speed skill shows custom configuration dialog
- ✅ Other skills show default configuration (unchanged)
- ✅ Speed config data stored correctly in state
- ✅ Navigation logic prepared for SpeedTrainingScreen (will be activated in Task 5)
- ✅ No compilation errors (flutter analyze passes)

**Dependencies**: Task 3 (SpeedConfigDialog)  
**Estimated**: 3 hours
**Actual**: ~30 minutes

---

## Task 5: Create Speed Training Screen - Core Timer ✅ COMPLETE
**Description**: Build main speed training screen with functional stopwatch timer

**Subtasks**:
- [x] 5.1: Create `lib/features/training/technical/screens/speed_training_screen.dart`
- [x] 5.2: Set up StatefulWidget with constructor params (targetTime, timeUnit, distance, distanceUnit, player)
- [x] 5.3: Initialize Stopwatch instance
- [x] 5.4: Implement `_startTimer()` method with Timer.periodic (10ms updates)
- [x] 5.5: Implement `_stopTimer()` method
- [x] 5.6: Implement `_resetTimer()` method
- [x] 5.7: Add state variables (_elapsedMilliseconds, _isRunning)
- [x] 5.8: Implement dispose() to cancel timers
- [x] 5.9: Build AppBar with title and save button (placeholder)
- [x] 5.10: Test timer start/stop/reset functionality
- [x] 5.11: Build target info card displaying configuration
- [x] 5.12: Build timer display with MM:SS.mmm format
- [x] 5.13: Build control buttons (Start/Stop, Reset, Record Time)
- [x] 5.14: Enable/disable buttons based on state
- [x] 5.15: Update skill_setup_screen.dart navigation to use SpeedTrainingScreen
- [x] 5.16: Fix deprecation warnings (withOpacity → withValues)

**Acceptance Criteria**:
- ✅ Stopwatch starts and stops correctly
- ✅ Timer updates every 10ms smoothly
- ✅ Reset returns timer to 00:00.000
- ✅ No memory leaks (timers canceled in dispose)
- ✅ Timer state persists during screen lifecycle
- ✅ AppBar displays with title and save button
- ✅ Target info card shows configuration (target time, distance, attempt #)
- ✅ Start/Stop button toggles correctly (green START / red STOP)
- ✅ Reset button only enabled when stopped and time > 0
- ✅ Record Time button only enabled when time > 0
- ✅ No compilation errors or warnings (flutter analyze passes)
- ✅ Navigation from skill setup works correctly

**Dependencies**: Task 4 (Navigation to SpeedTrainingScreen)  
**Estimated**: 6 hours
**Actual**: ~45 minutes

---

## Task 6: Build Timer Display Widget ✅ COMPLETE
**Description**: Create large, readable timer display showing MM:SS.mmm format

**Subtasks**:
- [x] 6.1: Create timer display widget (implemented inline in Task 5)
- [x] 6.2: Accept elapsedMilliseconds as parameter
- [x] 6.3: Format time as MM:SS.mmm
- [x] 6.4: Style with large monospace font (48sp)
- [x] 6.5: Add container with border and background
- [x] 6.6: Make responsive for different screen sizes
- [x] 6.7: Integrate widget into SpeedTrainingScreen
- [x] 6.8: Test display with various time values

**Acceptance Criteria**:
- ✅ Timer displays in MM:SS.mmm format
- ✅ Text is large and easily readable
- ✅ Monospace font ensures alignment
- ✅ Updates smoothly without flicker
- ✅ Reduced size per user feedback (48sp instead of 56sp)

**Dependencies**: Task 5 (SpeedTrainingScreen core)  
**Estimated**: 3 hours
**Actual**: Included in Task 5

---

## Task 7: Implement Control Buttons (Start/Stop/Reset) ✅ COMPLETE
**Description**: Add primary and secondary control buttons for timer operation

**Subtasks**:
- [x] 7.1: Build Start/Stop toggle button (green START / red STOP)
- [x] 7.2: Add icon change based on timer state
- [x] 7.3: Build Reset button (enabled only when stopped and time > 0)
- [x] 7.4: Build Record Time button (enabled when time > 0)
- [x] 7.5: Add button press handlers
- [x] 7.6: Style buttons to match design (colors, sizes, elevation)
- [x] 7.7: Add ripple effects and touch feedback
- [x] 7.8: Test button states and interactions

**Acceptance Criteria**:
- ✅ Start/Stop button toggles correctly
- ✅ Button colors change based on state (green/red)
- ✅ Reset only enabled when appropriate
- ✅ Record Time only enabled when time > 0
- ✅ Buttons are large and easily tappable (48dp+)
- ✅ Buttons match existing app theme

**Dependencies**: Task 6 (Timer display)  
**Estimated**: 4 hours
**Actual**: Included in Task 5

---

## Task 8: Implement Attempt Recording Logic ✅ COMPLETE
**Description**: Add functionality to record times and manage attempts list

**Subtasks**:
- [x] 8.1: Add _attempts list to state
- [x] 8.2: Add _currentAttemptNumber counter
- [x] 8.3: Implement `_recordTime()` method
- [x] 8.4: Calculate if attempt met target (convert time units)
- [x] 8.5: Create SpeedAttempt instance and add to list
- [x] 8.6: Increment attempt counter
- [x] 8.7: Auto-reset timer after recording
- [x] 8.8: Show SnackBar confirmation
- [x] 8.9: Update UI to reflect new attempt
- [x] 8.10: Test recording multiple attempts

**Acceptance Criteria**:
- ✅ Record Time button saves current time
- ✅ Attempt added to list with correct data
- ✅ metTarget calculated correctly
- ✅ Timer resets automatically after recording
- ✅ Confirmation message appears (with success/failure color)
- ✅ Can record unlimited attempts

**Dependencies**: Task 7 (Control buttons)  
**Estimated**: 4 hours
**Actual**: ~30 minutes

---

## Task 9: Build Attempts List View ✅ COMPLETE
**Description**: Create scrollable list displaying all recorded attempts with formatting

**Subtasks**:
- [x] 9.1: Add attempts list section to SpeedTrainingScreen
- [x] 9.2: Build attempt card widget
- [x] 9.3: Display attempt number badge (circular)
- [x] 9.4: Display formatted time (MM:SS.mmm)
- [x] 9.5: Display difference from target (+/- seconds)
- [x] 9.6: Add success/failure icon (checkmark/x)
- [x] 9.7: Color code cards (green for success, orange for failure)
- [x] 9.8: Handle empty state ("No attempts yet")
- [x] 9.9: Make list scrollable (ListView.builder)
- [x] 9.10: Test with multiple attempts (10+)

**Acceptance Criteria**:
- ✅ Attempts display in list format (newest first)
- ✅ Each card shows all required information
- ✅ Success/failure visually clear (colors + icons)
- ✅ Time difference calculated correctly
- ✅ List scrolls smoothly with many attempts
- ✅ Empty state shows helpful message with icon

**Dependencies**: Task 8 (Recording logic)  
**Estimated**: 5 hours
**Actual**: ~30 minutes

---

## Task 10: Build Target Info Card ✅ COMPLETE
**Description**: Create info card showing target time, distance, and current attempt number

**Subtasks**:
- [x] 10.1: Build container at top of screen
- [x] 10.2: Display target time with unit (e.g., "12.5 sec")
- [x] 10.3: Display distance with unit (e.g., "100 meters")
- [x] 10.4: Display current attempt number (e.g., "Attempt #3")
- [x] 10.5: Style with background and border
- [x] 10.6: Make responsive for different screen sizes
- [x] 10.7: Test with different configurations

**Acceptance Criteria**:
- ✅ Info card displays at top of screen
- ✅ All configuration details visible (target time + distance)
- ✅ Attempt counter updates correctly (dynamic with _currentAttemptNumber)
- ✅ Card is visually distinct from other elements
- ✅ Text is readable and well-formatted with icons
- ✅ Divider separates info from attempt counter

**Dependencies**: Task 9 (Attempts list)  
**Estimated**: 2 hours
**Actual**: Included in Task 5

**Notes**: Already implemented as `_buildTargetInfoCard()` in Task 5 with icons, dividers, and dynamic attempt counter.

---

## Task 11: Create Summary Modal Dialog ✅ COMPLETE
**Description**: Build completion summary showing session statistics

**Subtasks**:
- [x] 11.1: Create summary dialog widget
- [x] 11.2: Calculate total attempts
- [x] 11.3: Calculate best time (minimum)
- [x] 11.4: Calculate average time
- [x] 11.5: Calculate success rate (percentage met target)
- [x] 11.6: Display all statistics in formatted layout
- [x] 11.7: Show list of all times with success indicators
- [x] 11.8: Add "Record Another Attempt" button
- [x] 11.9: Add "Done" button
- [x] 11.10: Implement button actions (close modal / prepare for save)
- [x] 11.11: Test with various numbers of attempts
- [x] 11.12: Integrate _completeTraining() method in SpeedTrainingScreen
- [x] 11.13: Add validation to prevent completing without attempts
- [x] 11.14: Update AppBar icon to check icon

**Acceptance Criteria**:
- ✅ Modal displays after "Complete Training" pressed
- ✅ All statistics calculated correctly (total, best, average, success rate)
- ✅ Best time, average, and success rate accurate
- ✅ "Record Another Attempt" closes modal and returns to timer
- ✅ "Done" prepares to save session (will save in Task 12)
- ✅ Modal shows celebration icon and proper styling
- ✅ Statistics displayed in color-coded cards
- ✅ All attempts listed with times and success indicators
- ✅ Cannot complete training without recording attempts
- ✅ Modal matches design with scrollable content

**Dependencies**: Task 10 (Target info card)  
**Estimated**: 5 hours
**Actual**: ~45 minutes

---

## Task 12: Integrate Complete Training Flow ✅ COMPLETE
**Description**: Add Complete Training button and integrate full session lifecycle

**Subtasks**:
- [x] 12.1: Add "Complete Training" button to screen (already in AppBar)
- [x] 12.2: Implement `_completeTraining()` method (completed in Task 11)
- [x] 12.3: Show validation if no attempts recorded (completed in Task 11)
- [x] 12.4: Show summary modal with stats (completed in Task 11)
- [x] 12.5: Implement `_saveSession()` method
- [x] 12.6: Call StorageService.saveSpeedTrainingSession()
- [x] 12.7: Handle save errors with try/catch
- [x] 12.8: Show success/error SnackBar
- [x] 12.9: Navigate back to skill selection on Done
- [x] 12.10: Test complete flow from config to save
- [x] 12.11: Import StorageService
- [x] 12.12: Convert SpeedAttempt objects to JSON before saving
- [x] 12.13: Add loading indicator during save
- [x] 12.14: Add retry option on error

**Acceptance Criteria**:
- ✅ Complete Training button appears in AppBar (check icon)
- ✅ Cannot complete without recording attempts
- ✅ Summary modal shows correct data
- ✅ Session saves successfully to SharedPreferences
- ✅ User returns to skill selection after Done
- ✅ Error handling works for save failures with retry option
- ✅ Loading indicator shows during save
- ✅ Success confirmation message displays
- ✅ All attempts converted to JSON format for storage

**Dependencies**: Task 11 (Summary modal)  
**Estimated**: 4 hours
**Actual**: ~20 minutes

---

## Task 13: Add UI Polish and Refinements
**Description**: Polish UI details, animations, and user experience enhancements

**Subtasks**:
- [ ] 13.1: Add smooth transitions for button state changes
- [ ] 13.2: Add elevation and shadows to cards
- [ ] 13.3: Ensure consistent spacing throughout
- [ ] 13.4: Add loading state during save
- [ ] 13.5: Test color contrast for accessibility
- [ ] 13.6: Verify text sizes meet minimum readability
- [ ] 13.7: Test on small screen device (360x640)
- [ ] 13.8: Test on large screen/tablet
- [ ] 13.9: Verify all text fits without overflow
- [ ] 13.10: Add subtle animations (optional)

**Acceptance Criteria**:
- UI feels polished and professional
- All interactive elements have feedback
- Layout works on all screen sizes
- No text overflow or clipping
- Colors meet WCAG contrast guidelines
- App follows Material Design principles

**Dependencies**: Task 12 (Complete flow)  
**Estimated**: 4 hours

---

## Task 14: Write Widget Tests
**Description**: Create widget tests for all new components

**Subtasks**:
- [ ] 14.1: Write tests for SpeedConfigDialog
- [ ] 14.2: Write tests for SpeedTrainingScreen
- [ ] 14.3: Write tests for timer display widget
- [ ] 14.4: Write tests for attempt card widget
- [ ] 14.5: Test button enabled/disabled states
- [ ] 14.6: Test timer state transitions
- [ ] 14.7: Test attempt recording
- [ ] 14.8: Verify all tests pass with `flutter test`

**Acceptance Criteria**:
- All widget tests pass
- Test coverage > 80% for new code
- Tests verify UI behavior
- Tests catch regressions
- Tests run in <10 seconds

**Dependencies**: Task 13 (UI polish)  
**Estimated**: 6 hours

---

## Task 15: Integration Testing and QA
**Description**: End-to-end testing and quality assurance

**Subtasks**:
- [ ] 15.1: Run Test Case 1 (Configure Speed Training)
- [ ] 15.2: Run Test Case 2 (Record Single Sprint)
- [ ] 15.3: Run Test Case 3 (Multiple Attempts)
- [ ] 15.4: Run Test Case 4 (Record Additional from Summary)
- [ ] 15.5: Run Test Case 5 (Data Persistence)
- [ ] 15.6: Test timer accuracy (compare with external stopwatch)
- [ ] 15.7: Test with 20+ attempts (stress test)
- [ ] 15.8: Test rapid button pressing
- [ ] 15.9: Test app backgrounding during timer
- [ ] 15.10: Verify flutter analyze shows 0 errors
- [ ] 15.11: Fix any bugs found during testing
- [ ] 15.12: Final code review

**Acceptance Criteria**:
- All test cases pass
- Timer accurate within ±50ms
- No crashes or errors
- Performance is smooth
- flutter analyze returns 0 errors
- Code follows project conventions

**Dependencies**: Task 14 (Widget tests)  
**Estimated**: 8 hours

---

## Summary

**Total Tasks**: 15  
**Total Estimated Time**: 68 hours (~9 working days)  
**Recommended Sprint**: 2 weeks (allows buffer for unknowns)

**Critical Path**:
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 7 → Task 8 → Task 9 → Task 10 → Task 11 → Task 12 → Task 13 → Task 14 → Task 15

**Can Work in Parallel** (after Task 3):
- Task 6 (Timer display widget) 
- Task 10 (Target info card)
- Task 11 (Summary modal) can start design while Task 8-9 in progress

---

## Definition of Done

A task is considered complete when:
- [ ] All subtasks are checked off
- [ ] Code compiles without errors
- [ ] Code follows project style guide
- [ ] Unit/widget tests written and passing
- [ ] Manual testing performed
- [ ] Code reviewed (if team process)
- [ ] Acceptance criteria met
- [ ] No regressions introduced

---

## Notes for Implementation

1. **Start with data layer** (Tasks 1-2) before UI to ensure solid foundation
2. **Test frequently** during development, not just at the end
3. **Commit often** with descriptive messages
4. **Run flutter analyze** after each task completion
5. **Test on real device** early and often, not just emulator
6. **Keep requirements.md and design.md open** for reference
7. **Update this task list** as you discover new subtasks

---

**Status**: Ready for development ✅  
**Next Action**: Begin Task 1 - Create SpeedAttempt Data Model
