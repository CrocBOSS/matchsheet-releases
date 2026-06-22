# Requirements: Speed Skill Timer Enhancement

**Feature**: Convert the Speed skill in Technical Performance Training to use a timer-based tracking system instead of the success/neutral/fail button system.

**Date**: June 22, 2026  
**Status**: Draft  
**Priority**: High

---

## 1. Business Requirements

### 1.1 Problem Statement
Currently, the "Speed" skill in the Technical Performance Training module uses the same success/neutral/fail tracking mechanism as other technical skills. However, speed training is better measured with precise timing and distance, similar to how strength training uses a progressive rep counter.

### 1.2 User Goals
- **Coaches/Trainers** want to accurately track player sprint times with millisecond precision
- **Players** want to see their sprint performance against target times
- **Both** want a simple start/stop interface similar to the strength training module

### 1.3 Success Criteria
- Speed skill configuration allows setting target time and distance
- Timer interface shows hours:minutes:seconds:milliseconds format
- Start/Stop button controls timer (similar to strength training's rep counter)
- Training session saves time records for each attempt
- Summary shows all recorded times and best performance

---

## 2. Functional Requirements

### 2.1 Speed Skill Configuration

**FR-1.1**: When selecting the "Speed" skill from the skill list, the configuration dialog must include:
- **Target Time** field (numeric input with unit selector dropdown)
  - Units: "seconds" (default) or "minutes"
  - Example: 12.5 seconds or 1.5 minutes
  - Display format: Show as entered (e.g., "12.5 sec" or "1.5 min")
- **Distance** field (numeric with unit selector: meters/yards)
- **No limit on attempts** - user can record unlimited attempts and decide when to stop

**FR-1.2**: Configuration validation:
- Target time must be > 0
- Distance must be > 0

### 2.2 Timer Interface

**FR-2.1**: Speed tracking screen must display:
- **Timer display** showing 00:00:00.000 (MM:SS.mmm format - minutes:seconds:milliseconds)
- **Target info card** showing: Target Time (in configured unit), Distance
- **Current Attempt counter** showing "Attempt #X" (increments after each recording)
- **Large Start/Stop button** (similar to strength training's main button)
- **Reset button** (to reset current timer)
- **Record Time button** (saves the time and allows recording another attempt)

**FR-2.2**: Timer behavior:
- **Start** button: Begins timer from 00:00:00.000
- **Stop** button: Pauses timer at current time
- **Reset** button: Resets timer to 00:00:00.000 (only available when stopped)
- **Record Time** button: 
  - Saves current time as an attempt
  - Increments attempt counter
  - Resets timer to 00:00:00.000
  - Stays on same screen for next attempt

**FR-2.3**: Timer modes (select one implementation):
- **Option A (Count-up)**: Timer starts at 00:00:00.000 and counts up
- **Option B (Countdown)**: Timer starts at target time and counts down to 00:00:00.000

**Recommendation**: Use Option A (count-up) for simplicity and clarity.

### 2.3 Attempt Recording

**FR-3.1**: For each completed attempt, record:
- Attempt number (1, 2, 3, ...)
- Recorded time (in milliseconds internally, displayed as MM:SS.mmm)
- Whether it met target (boolean: recordedTime <= targetTime)
- Timestamp of attempt

**FR-3.2**: Display recorded attempts in a list/table showing:
- Attempt #
- Time
- Status badge (✓ Met Target / ✗ Missed Target)
- Time difference from target (+/- seconds)

### 2.4 Training Completion

**FR-4.1**: After user chooses to end the session (via "Complete Training" button), show summary modal with:
- Total attempts recorded
- Best time
- Average time
- Number of attempts that met target
- Percentage of success rate
- List of all recorded times

**FR-4.2**: Summary actions:
- **Record Another Attempt** button (closes modal, returns to timer for one more)
- **Done** button (saves session and returns to skill selection)

---

## 3. Non-Functional Requirements

### 3.1 Performance
- Timer must update display at minimum 10ms intervals for smooth millisecond display
- Timer must continue accurately even when app is in background (using Dart isolates if needed)

### 3.2 Usability
- Large, accessible Start/Stop button for easy tapping during physical activity
- Clear visual distinction between running, stopped, and reset states
- Haptic feedback on Start/Stop button press (if available)

### 3.3 Data Persistence
- All timer data persists using existing StorageService
- Speed sessions saved separately with 'speed_training' key
- Data structure compatible with existing training export functionality

---

## 4. User Stories

### US-1: Configure Speed Training
**As a** coach  
**I want to** configure speed training with target time and distance  
**So that** I can set performance goals for my players

**Acceptance Criteria**:
- Can set target time as numeric value (e.g., 12.5)
- Can choose time unit from dropdown: seconds (default) or minutes
- Can set distance with unit (meters/yards)
- Configuration validates input before starting training
- No fixed number of attempts - unlimited recording

---

### US-2: Record Sprint Times
**As a** coach  
**I want to** use a Start/Stop timer with millisecond precision  
**So that** I can accurately record player sprint times

**Acceptance Criteria**:
- Timer displays milliseconds (00:00.000 format for seconds view)
- Start button begins timer
- Stop button pauses timer at current time
- Record Time button saves time and allows recording another
- Can see all recorded attempts during session
- Can choose to end session anytime with "Complete Training" button

---

### US-3: Review Performance
**As a** coach  
**I want to** see a summary of all sprint attempts  
**So that** I can evaluate player speed performance

**Acceptance Criteria**:
- Summary shows best time, average time, success rate
- Can see which attempts met the target time
- Can record another attempt from summary
- Can end session and save to history for later review

---

## 5. Data Model Changes

### 5.1 TechnicalSkill Model Extension

For the Speed skill specifically, the configuration needs additional fields:

```dart
// When skill.key == 'speed'
class SpeedSkillConfig {
  final double targetTime; // numeric value (e.g., 12.5)
  final String targetTimeUnit; // "seconds" or "minutes"
  final double distance; // numeric value
  final String distanceUnit; // "meters" or "yards"
  // No totalAttempts - unlimited attempts allowed
}
```

### 5.2 Training Entry Custom Stats

For Speed training sessions, store in `customStats`:

```dart
{
  'speed_targetTime': 12.5, // numeric value
  'speed_targetTimeUnit': 'seconds', // or 'minutes'
  'speed_distance': 100.0,
  'speed_distanceUnit': 'meters',
  'speed_totalAttempts': 5, // dynamically counted
  'speed_attempt1_time': 12234, // milliseconds
  'speed_attempt1_metTarget': true,
  'speed_attempt2_time': 12867, // milliseconds
  'speed_attempt2_metTarget': false,
  // ... etc
  'speed_bestTime': 12234,
  'speed_averageTime': 12550.5,
}
```

---

## 6. Design Constraints

### 6.1 Code Constraints
- Must maintain compatibility with existing TechnicalSkill model
- Must use existing StorageService for persistence
- Must follow current technical training module patterns
- Should reuse UI components where possible (buttons, cards, modals)

### 6.2 UI Constraints
- Must work on small mobile screens (minimum 360px width)
- Timer must be large and easily readable from distance
- Start/Stop button must be large enough for easy tapping during activity
- Must follow existing app theme and color scheme

---

## 7. Out of Scope

The following are explicitly **NOT** included in this feature:

- ❌ GPS integration for automatic distance tracking
- ❌ Audio cues for start/stop
- ❌ Comparison with previous speed training sessions (analytics)
- ❌ Lap timing (only single sprint timing)
- ❌ Split times for interval training
- ❌ Modifications to other technical skills
- ❌ Video recording integration
- ❌ Heart rate monitoring

These may be considered for future iterations.

---

## 8. Open Questions

1. **Q**: Should the timer count up from zero or count down from target time?  
   **A**: Count up from zero (simpler, more intuitive)

2. **Q**: What happens if user accidentally closes app during timing?  
   **A**: Timer stops, current incomplete attempt is discarded (will implement in later version if needed)

3. **Q**: Should we allow editing recorded times after they're saved?  
   **A**: No, times are final once recorded (integrity of data)

4. **Q**: Should Speed skill still be usable with old success/neutral/fail system?  
   **A**: No, Speed becomes timer-only. Other skills unchanged.

5. **Q**: Format for target time input - text field or dropdown with numeric input?  
   **A**: Numeric input field with dropdown for unit selection (seconds default, or minutes)

---

## 9. Dependencies

- Existing Flutter timer APIs (`Stopwatch`, `Timer.periodic`)
- Existing `TechnicalSkill` model
- Existing `StorageService`
- Existing `TechnicalPerformanceScreen` routing

---

## 10. Assumptions

- Users have basic understanding of time formats (MM:SS.mmm)
- Device has sufficient performance for 10ms timer updates
- Users will manually start/stop timer (not automatic sensors)
- One player at a time performs speed training (no multi-player race timing)

---

## 11. Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Timer drift/inaccuracy | High | Low | Use Dart `Stopwatch` class which is precise |
| App backgrounding stops timer | Medium | Medium | Document behavior, consider future background task support |
| Confusing for users used to old system | Low | Medium | Clear UI labels, help text on first use |
| Data migration from old speed entries | Low | Low | Old speed data remains in old format, new format used going forward |

---

## 12. Acceptance Testing Plan

### Test Case 1: Configure Speed Training
1. Open Technical Training
2. Select "Speed" skill
3. Configure: Target 15 seconds, 100 meters
4. Verify configuration saved
5. Start training

**Expected**: Configuration dialog accepts numeric input with unit dropdown, training screen opens with correct target info

### Test Case 2: Record Single Sprint
1. Configure speed training (target 15 seconds)
2. Tap Start button
3. Wait 5 seconds
4. Tap Stop button
5. Verify time is approximately 00:05.xxx
6. Tap Record Time button
7. Verify attempt #1 recorded
8. Choose "Complete Training"

**Expected**: Timer displays correct time, attempt recorded, can end session anytime

### Test Case 3: Multiple Attempts with Unlimited Recording
1. Configure speed training (target 12 seconds)
2. Record attempt 1: ~10 seconds
3. Record attempt 2: ~12 seconds  
4. Record attempt 3: ~9 seconds
5. Tap "Complete Training"
6. View summary

**Expected**: All 3 times recorded, best time = 9s, average calculated correctly

### Test Case 4: Record Additional Attempt from Summary
1. Complete 2 attempts
2. Tap "Complete Training"
3. View summary
4. Tap "Record Another Attempt"
5. Record additional attempt
6. Tap "Complete Training" again

**Expected**: Can return from summary to record more, summary updates with new data

### Test Case 5: Data Persistence
1. Complete speed training session
2. Save session
3. Close app
4. Reopen app
5. View Saved Training history

**Expected**: Speed session appears in history with all recorded times

---

**End of Requirements Document**
