# Design Document: Speed Skill Timer Enhancement

**Feature**: Speed Skill Timer-based Tracking System  
**Date**: June 22, 2026  
**Status**: Draft  
**Related**: requirements.md

---

## 1. Design Overview

### 1.1 Summary
This design converts the "Speed" skill in the Technical Performance Training module from a success/neutral/fail button system to a precision timer-based tracking system, similar to the strength training module's progressive counter design.

### 1.2 Design Goals
- Reuse existing strength training UI patterns for consistency
- Minimal changes to existing TechnicalSkill model
- Add Speed-specific timer logic without affecting other technical skills
- Maintain compatibility with existing StorageService

### 1.3 Design Principles
- **Consistency**: Match strength training's large button interaction model
- **Simplicity**: Single-purpose timer screen (no complex multi-skill tracking)
- **Precision**: Millisecond-accurate timing using Dart's Stopwatch
- **Flexibility**: Unlimited attempts with user-controlled session end

---

## 2. Architecture Overview

### 2.1 Component Structure

```
lib/features/training/technical/
├── models/
│   ├── technical_skill.dart          (MODIFY - add timer fields)
│   └── speed_timer_data.dart         (NEW - timer state model)
├── screens/
│   ├── skill_setup_screen.dart       (MODIFY - detect Speed, show different config)
│   ├── technical_screen.dart         (MODIFY - route to speed timer for Speed skill)
│   ├── speed_timer_screen.dart       (NEW - timer interface)
│   └── saved_sessions_screen.dart    (existing - no changes)
└── widgets/
    └── speed_timer_display.dart      (NEW - reusable timer widget)
```

### 2.2 Data Flow

```
User selects "Speed" skill
    ↓
skill_setup_screen.dart detects key == 'speed'
    ↓
Shows custom config dialog (target time + unit, distance)
    ↓
User taps "Start Training"
    ↓
┌─────────────────────────────────────────────────────────┐
│          TechnicalSetupScreen (Existing)                │
│  - Loads skills from StorageService                     │
│  - Detects if skill.key == 'speed'                      │
│  - Shows SpeedConfigDialog (NEW)                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Navigate with speed config params
                     ▼
┌─────────────────────────────────────────────────────────┐
│       SpeedTrainingScreen (NEW Widget)                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Timer: Stopwatch + Timer.periodic                │  │
│  │  State: running/stopped/idle                      │  │
│  │  Attempts: List<SpeedAttempt>                     │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  UI Components:                                          │
│  - SpeedTimerDisplay (MM:SS.mmm)                        │
│  - Start/Stop/Reset Buttons                             │
│  - Record Time Button                                   │
│  - Attempts List View                                   │
│  - Complete Training Button                             │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Save session
                     ▼
┌─────────────────────────────────────────────────────────┐
│         StorageService (Existing + New Method)          │
│  - saveSpeedTrainingSession() (NEW)                     │
│  - Stores in SharedPreferences                          │
│  - Key: 'speed_training_sessions'                       │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Component Overview

**Modified Components:**
1. `TechnicalSetupScreen` - Add Speed skill detection and special config dialog
2. `TechnicalSkill` model - No changes (uses existing fields creatively)

**New Components:**
3. `SpeedTrainingScreen` - Complete new screen for timer-based tracking
4. `SpeedConfigDialog` - Custom configuration dialog for Speed skill
5. `SpeedAttempt` model - Lightweight data class for attempt records
6. StorageService extension - New method `saveSpeedTrainingSession()`

---

## 3. Data Models

### 3.1 SpeedAttempt Model (NEW)

```dart
class SpeedAttempt {
  final int attemptNumber;
  final int timeInMilliseconds;
  final bool metTarget;
  final DateTime timestamp;
  
  SpeedAttempt({
    required this.attemptNumber,
    required this.timeInMilliseconds,
    required this.metTarget,
    required this.timestamp,
  });
  
  String get formattedTime {
    final minutes = (timeInMilliseconds ~/ 60000).toString().padLeft(2, '0');
Routes to speed_timer_screen.dart (not technical_screen.dart)
    ↓
User interacts with timer (Start/Stop/Record)
    ↓
Records stored in TrainingEntry.customStats
    ↓
User taps "Complete Training"
    ↓
Summary modal displays stats
    ↓
User taps "Done" → saves session via StorageService
```

---

## 3. Screen Designs

### 3.1 Configuration Screen (skill_setup_screen.dart)

**MODIFY EXISTING**: Add conditional logic for Speed skill

**When Speed skill is selected, show custom dialog:**

```
┌─────────────────────────────────────┐
│  Configure Speed                 ✕  │
├─────────────────────────────────────┤
│                                     │
│  Target Time                        │
│  ┌─────────────┐  ┌──────────────┐ │
│  │    12.5     │  │  Seconds  ▼ │ │
│  └─────────────┘  └──────────────┘ │
│                                     │
│  Distance                           │
│  ┌─────────────┐  ┌──────────────┐ │
│  │     100     │  │  Meters   ▼ │ │
│  └─────────────┘  └──────────────┘ │
│                                     │
├─────────────────────────────────────┤
│          [Cancel]  [Confirm]        │
└─────────────────────────────────────┘
```

**Fields:**
- Target Time: TextField (numeric only, decimal allowed)
- Time Unit: DropdownButton ["Seconds" (default), "Minutes"]
- Distance: TextField (numeric only, decimal allowed)
- Distance Unit: DropdownButton ["Meters" (default), "Yards"]

**Validation:**
    final seconds = ((timeInMilliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (timeInMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'attemptNumber': attemptNumber,
      'timeInMilliseconds': timeInMilliseconds,
      'metTarget': metTarget,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory SpeedAttempt.fromJson(Map<String, dynamic> json) {
    return SpeedAttempt(
      attemptNumber: json['attemptNumber'] as int,
      timeInMilliseconds: json['timeInMilliseconds'] as int,
      metTarget: json['metTarget'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
```

### 3.2 TechnicalSkill Model (Reuse Existing)

No changes needed. For Speed skill configuration:
- `targetScore` → stores target time as numeric (e.g., 12.5)
- `totalReps` → stores distance as numeric (e.g., 100)
- `unit` → stores combined format: "12.5sec_100m" or "1.5min_50yd"

This clever reuse avoids model changes while storing all needed data.

### 3.3 Storage Structure

**SharedPreferences Key**: `speed_training_sessions`

**JSON Structure**:
```json
{
  "sessions": [
    {
      "sessionId": "uuid-string",
      "playerName": "John Doe",
      "playerId": "player_123",
      "date": "2026-06-22T10:30:00.000Z",
      "targetTime": 12.5,
      "targetTimeUnit": "seconds",
      "distance": 100.0,
      "distanceUnit": "meters",
      "attempts": [
        {
          "attemptNumber": 1,
          "timeInMilliseconds": 12234,
          "metTarget": true,
          "timestamp": "2026-06-22T10:31:15.000Z"
        }
      ],
      "bestTime": 12234,
      "averageTime": 12550.5,
      "successRate": 0.66
    }
  ]
}
```

---

## 4. Screen Designs

### 4.1 Configuration Dialog (Modified Flow)

**Location**: `TechnicalSetupScreen._showSkillConfigDialog()`

**Detection Logic**:
- Target time > 0
- Distance > 0
- Show SnackBar on validation failure

---

### 3.2 Speed Timer Screen (NEW: speed_timer_screen.dart)

**PRIMARY SCREEN**: Timer interface for recording sprint times

```
┌─────────────────────────────────────┐
│  ← Speed                         💾 │  AppBar
├─────────────────────────────────────┤
│                                     │
│  ╔═══════════════════════════════╗ │  Target Info Card
│  ║ Target: 12.5 sec              ║ │
│  ║ Distance: 100 meters          ║ │
│  ║ Attempt #3                    ║ │
│  ╚═══════════════════════════════╝ │
│                                     │
│         ╔═══════════════╗          │  Timer Display
│         ║               ║          │  (Large, bold)
│         ║  00:12.345    ║          │
│         ║               ║          │
│         ╚═══════════════╝          │
│         MM:SS.mmm                  │
│                                     │
│  ┌─────────────────────────────┐  │  Start/Stop Button
│  │                              │  │  (Changes color/text)
│  │      🟢 START TIMER          │  │  Green when stopped
│  │                              │  │  Red when running
│  └─────────────────────────────┘  │
│                                     │
│        [Reset]  [Record Time]      │  Action Buttons
│                                     │
│  ────────────────────────────────  │  Separator
│                                     │
│  Recorded Attempts:                │  Attempts List
│  ✓ #1: 00:11.234 (-1.266s)        │
│  ✓ #2: 00:12.100 (-0.400s)        │
│                                     │
│  ┌─────────────────────────────┐  │  Complete Button
│  │   ✓ Complete Training        │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Components:**
1. **Target Info Card**: Shows target time (in configured unit), distance, current attempt #
2. **Timer Display**: Large, readable 00:MM.SSS format
3. **Start/Stop Button**: Toggle button (green START / red STOP)
4. **Reset Button**: Resets timer to 00:00.000 (only enabled when stopped)
5. **Record Time Button**: Saves current time as attempt, increments counter
6. **Attempts List**: Scrollable list showing all recorded attempts
7. **Complete Training Button**: Ends session, shows summary

---

```dart
if (skill.key == 'speed') {
  _showSpeedConfigDialog(skill);
} else {
  _showSkillConfigDialog(skill); // Existing dialog
}
```

**Speed Config Dialog Layout**:
```
┌─────────────────────────────────────────┐
│  Configure Speed                   [X]  │
├─────────────────────────────────────────┤
│                                         │
│  Target Time                            │
│  ┌────────────┬──────────────────────┐  │
│  │   12.5     │ ▼ seconds           │  │
│  └────────────┴──────────────────────┘  │
│  (Numeric input + Dropdown)             │
│                                         │
│  Distance                               │
│  ┌────────────┬──────────────────────┐  │
│  │   100      │ ▼ meters            │  │
│  └────────────┴──────────────────────┘  │
│  (Numeric input + Dropdown)             │
│                                         │
│  ℹ️ Unlimited attempts allowed          │
│                                         │
│         [Cancel]  [Start Training]      │
└─────────────────────────────────────────┘
```

**Fields**:
- **Target Time**: `TextFormField` (numeric) + `DropdownButton` (seconds/minutes)
- **Distance**: `TextFormField` (numeric) + `DropdownButton` (meters/yards)
- **Validation**: Both > 0

### 4.2 Speed Training Screen (NEW)

**File**: `lib/features/training/technical/screens/speed_training_screen.dart`

**Layout**:
```
┌─────────────────────────────────────────┐
│  ← Speed Training              [Save]   │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Target: 12.5 sec │ Distance: 100m│  │
│  │  Attempt #3                       │  │
│  └───────────────────────────────────┘  │
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   00:12.345     │             │
│         │                 │             │
│         └─────────────────┘             │
│              (Large Timer)              │
│                                         │
│     ┌────────┐ ┌────────┐ ┌─────────┐  │
│     │ START  │ │ RESET  │ │ RECORD  │  │
│     └────────┘ └────────┘ │  TIME   │  │
│     (or STOP)              └─────────┘  │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Recorded Attempts:                     │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ #1: 00:11.950  ✓ (-0.550s)       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ #2: 00:13.100  ✗ (+0.600s)       │  │
│  └───────────────────────────────────┘  │
│                                         │
│     [Complete Training]                 │
│                                         │
└─────────────────────────────────────────┘
```

**Widget Hierarchy**:
### 3.3 Summary Modal (Dialog)

**TRIGGERED BY**: "Complete Training" button

```
┌─────────────────────────────────────┐
│  Speed Training Complete! 🎉        │
├─────────────────────────────────────┤
│                                     │
│  Total Attempts: 3                  │
│  Best Time: 00:11.234               │
│  Average Time: 00:11.778            │
│  Success Rate: 100% (3/3)           │
│                                     │
│  All Times:                         │
│  1. 00:11.234 ✓                    │
│  2. 00:12.100 ✓                    │
│  3. 00:12.000 ✓                    │
│                                     │
├─────────────────────────────────────┤
│  [Record Another Attempt]  [Done]   │
└─────────────────────────────────────┘
```

**Calculations:**
- Best Time: min(all recorded times)
- Average Time: sum(times) / count
- Success Rate: count(time <= target) / total * 100%

**Actions:**
- "Record Another Attempt": Dismiss modal, return to timer screen
- "Done": Save session via StorageService, pop back to skill_setup_screen

---

## 4. Data Models

### 4.1 TechnicalSkill Model (MODIFY)

**File**: `lib/features/training/technical/models/technical_skill.dart`

**No breaking changes** - Speed skill uses existing fields differently:

```dart
class TechnicalSkill {
  final String key;              // "speed"
  final String label;            // "Speed"
  final double targetScore;      // Repurposed: stores target time value (12.5)
  final int totalReps;           // Repurposed: stores 0 (unlimited attempts)
  final String unit;             // Repurposed: stores time unit ("seconds" or "minutes")

  // Existing methods unchanged
  TechnicalSkill({...});
  Map<String, dynamic> toJson() {...}
  factory TechnicalSkill.fromJson(Map<String, dynamic> json) {...}
  StatType toStatType() {...}
  TechnicalSkill copyWith({...}) {...}
}
```

**Field Reuse Strategy:**
- `targetScore` → target time value (e.g., 12.5)
- `totalReps` → 0 (indicates unlimited attempts)
- `unit` → time unit ("seconds" or "minutes")

**Why this approach?**
- No breaking changes to existing model
- Backward compatible with other technical skills
- Reuses existing storage infrastructure

---

### 4.2 Speed Timer Data Model (NEW)

**File**: `lib/features/training/technical/models/speed_timer_data.dart`

**Purpose**: Hold timer state and recorded attempts during session

```dart
class SpeedAttempt {
  final int attemptNumber;
  final int timeInMilliseconds;
  final bool metTarget;
  final DateTime timestamp;

  SpeedAttempt({
    required this.attemptNumber,
    required this.timeInMilliseconds,
    required this.metTarget,
    required this.timestamp,
  });

  String getFormattedTime() {
    final minutes = timeInMilliseconds ~/ 60000;
    final seconds = (timeInMilliseconds % 60000) ~/ 1000;
    final millis = timeInMilliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
  }

  String getDifferenceFromTarget(int targetInMillis) {
    final diff = timeInMilliseconds - targetInMillis;
    final sign = diff > 0 ? '+' : '';
    final seconds = (diff.abs() / 1000).toStringAsFixed(3);
    return '$sign${seconds}s';
  }

  Map<String, dynamic> toJson() {
    return {
      'attemptNumber': attemptNumber,
      'timeInMilliseconds': timeInMilliseconds,
      'metTarget': metTarget,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SpeedAttempt.fromJson(Map<String, dynamic> json) {
    return SpeedAttempt(
      attemptNumber: json['attemptNumber'] as int,
      timeInMilliseconds: json['timeInMilliseconds'] as int,
      metTarget: json['metTarget'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
```

```
SpeedTrainingScreen (StatefulWidget)
├── AppBar (with Save button)
├── SingleChildScrollView
│   └── Padding
│       └── Column
│           ├── _TargetInfoCard (Target time, distance, attempt #)
│           ├── _TimerDisplay (Large MM:SS.mmm display)
│           ├── _ControlButtons (Start/Stop, Reset, Record Time)
│           ├── Divider
│           ├── _AttemptsListView (Recorded attempts)
│           └── _CompleteTrainingButton
```

### 4.3 Summary Modal (Similar to Strength Training)

**Triggered by**: "Complete Training" button

**Layout**:
```
┌─────────────────────────────────────────┐
│  Speed Training Complete!          [X]  │
├─────────────────────────────────────────┤
│                                         │
│  📊 Summary                             │
│                                         │
│  Total Attempts: 3                      │
│  Best Time: 00:11.950 ⭐                │
│  Average Time: 00:12.428                │
│  Success Rate: 66% (2/3 met target)     │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  All Times:                             │
│  #1: 00:11.950 ✓                        │
│  #2: 00:13.100 ✗                        │
│  #3: 00:12.234 ✓                        │
│                                         │
│   [Record Another Attempt]  [Done]      │
│                                         │
└─────────────────────────────────────────┘
```

**Actions**:
- **Record Another Attempt**: `Navigator.pop()` (returns to timer screen)
- **Done**: Save session + `Navigator.pop()` twice (return to skill selection)

---

## 5. State Management

### 5.1 SpeedTrainingScreen State

```dart
class _SpeedTrainingScreenState extends State<SpeedTrainingScreen> {
  // Configuration (from constructor params)
  late double targetTime;
  late String targetTimeUnit;
  late double distance;
  late String distanceUnit;
  late TrainingPlayer player;
  
  // Timer state
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedMilliseconds = 0;
  
  // Attempt tracking
  List<SpeedAttempt> _attempts = [];
  int _currentAttemptNumber = 1;
  
  // UI state
  bool get isRunning => _stopwatch.isRunning;
  bool get canReset => !isRunning && _elapsedMilliseconds > 0;
  bool get canRecordTime => _elapsedMilliseconds > 0;
}
```

### 5.2 Timer Logic

**Start Timer**:
```dart
void _startTimer() {
  _stopwatch.start();
  _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
    if (mounted) {
      setState(() {
        _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
      });
    }
  });
}
```

**Stop Timer**:
```dart
void _stopTimer() {
  _stopwatch.stop();
  _timer?.cancel();
  setState(() {
    _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
  });
}
```

**Reset Timer**:
```dart
void _resetTimer() {
  if (!isRunning) {
    _stopwatch.reset();
    setState(() {
      _elapsedMilliseconds = 0;
    });
  }
}
```

**Record Time**:
---

### 4.3 Storage Format (TrainingEntry.customStats)

**File**: Existing `TrainingEntry` model - no changes needed

**Speed session data stored in customStats map:**

```dart
{
  // Configuration
  'speed_targetTime': 12.5,                    // double
  'speed_targetTimeUnit': 'seconds',           // string
  'speed_distance': 100.0,                     // double
  'speed_distanceUnit': 'meters',              // string
  
  // Session results
  'speed_totalAttempts': 3,                    // int
  'speed_bestTime': 11234,                     // int (milliseconds)
  'speed_averageTime': 11778,                  // int (milliseconds)
  'speed_successRate': 100.0,                  // double (percentage)
  
  // Individual attempts
  'speed_attempt1_time': 11234,                // int (milliseconds)
  'speed_attempt1_metTarget': true,            // bool
  'speed_attempt1_timestamp': '2026-06-22T...',// string (ISO8601)
  
  'speed_attempt2_time': 12100,
  'speed_attempt2_metTarget': true,
  'speed_attempt2_timestamp': '2026-06-22T...',
  
  'speed_attempt3_time': 12000,
  'speed_attempt3_metTarget': true,
  'speed_attempt3_timestamp': '2026-06-22T...',
  
  // ... additional attempts as needed
}
```

**Key Design Decisions:**
- Use `speed_` prefix for all keys (namespace isolation)
- Store times in milliseconds internally (precision + easy math)
- Store timestamps for each attempt (future analytics)
- Dynamic key generation: `speed_attempt${n}_time`

---

## 5. Technical Implementation

### 5.1 Timer Implementation

**Use Dart's Stopwatch class for precision timing:**

```dart
class SpeedTimerState {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _updateTimer;
  int currentTimeInMillis = 0;
  bool isRunning = false;

  void start() {
    _stopwatch.start();
    isRunning = true;
    
    // Update UI every 10ms for smooth milliseconds display
    _updateTimer = Timer.periodic(Duration(milliseconds: 10), (_) {
      currentTimeInMillis = _stopwatch.elapsedMilliseconds;
      notifyListeners(); // or setState() in StatefulWidget
    });
  }

  void stop() {
    _stopwatch.stop();
    _updateTimer?.cancel();
    isRunning = false;
    currentTimeInMillis = _stopwatch.elapsedMilliseconds;
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    currentTimeInMillis = 0;
    isRunning = false;
    notifyListeners();
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}
```

```dart
void _recordTime() {
  if (_elapsedMilliseconds == 0) return;
  
  // Calculate target in milliseconds for comparison
  final targetInMs = _getTargetInMilliseconds();
  final metTarget = _elapsedMilliseconds <= targetInMs;
  
  final attempt = SpeedAttempt(
    attemptNumber: _currentAttemptNumber,
    timeInMilliseconds: _elapsedMilliseconds,
    metTarget: metTarget,
    timestamp: DateTime.now(),
  );
  
  setState(() {
    _attempts.add(attempt);
    _currentAttemptNumber++;
  });
  
  // Auto-reset for next attempt
  _resetTimer();
  
  // Show snackbar confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Attempt #${attempt.attemptNumber} recorded: ${attempt.formattedTime}'),
      duration: Duration(milliseconds: 1500),
    ),
  );
}
```

### 5.3 Lifecycle Management

**initState**:
```dart
@override
void initState() {
  super.initState();
  // Initialize from widget params
  targetTime = widget.targetTime;
  targetTimeUnit = widget.targetTimeUnit;
  distance = widget.distance;
  distanceUnit = widget.distanceUnit;
  player = widget.player;
}
```

**dispose**:
```dart
@override
void dispose() {
  _stopTimer();
  _timer?.cancel();
  _stopwatch.stop();
  super.dispose();
}
```

---

## 6. Navigation Flow

### 6.1 From Skill Selection to Speed Training

**Current Flow (Other Skills)**:
```
TechnicalSetupScreen 
  → _showSkillConfigDialog() 
  → Navigate to TechnicalPerformanceScreen (with success/neutral/fail buttons)
```

**New Flow (Speed Skill)**:
```
TechnicalSetupScreen 
  → Detect skill.key == 'speed'
  → _showSpeedConfigDialog() (custom dialog)
  → Navigate to SpeedTrainingScreen (NEW, with timer)
```

**Navigation Code**:
```dart
// In TechnicalSetupScreen
void _startTraining() {
  if (selectedSkill == null || !hasConfiguredTargets) return;

  if (selectedSkill!.key == 'speed') {
    // Parse speed-specific config from unit field
    final configParts = selectedUnit.split('_');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeedTrainingScreen(
          targetTime: selectedTargetScore, // reusing this field
          targetTimeUnit: configParts[0].replaceAll(RegExp(r'[0-9.]'), ''), // 'sec' or 'min'
          distance: selectedTotalReps.toDouble(), // reusing this field
          distanceUnit: configParts[1], // 'm' or 'yd'
          player: widget.player,
        ),
      ),
    );
  } else {
    // Existing navigation for other skills
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechnicalPerformanceScreen(
          selectedStat: selectedSkill!.toStatType(),
          targetScore: selectedTargetScore,
          totalReps: selectedTotalReps,
          player: widget.player,
        ),
      ),
    );
  }
}
```

### 6.2 Summary Modal to Actions

**Record Another Attempt**:
**Why Stopwatch?**
- Native Dart class, highly precise
- Pauses correctly (not dependent on wall clock)
- Handles device sleep/wake gracefully
- No drift over time

---

### 5.2 Screen State Management

**File**: `speed_timer_screen.dart`

**State Variables:**

```dart
class _SpeedTimerScreenState extends State<SpeedTimerScreen> {
  // Timer state
  late Stopwatch _stopwatch;
  Timer? _updateTimer;
  int _currentTimeInMillis = 0;
  bool _isRunning = false;
  
  // Configuration (passed from setup screen)
  late double targetTime;
  late String targetTimeUnit;
  late double distance;
  late String distanceUnit;
  
  // Session data
  List<SpeedAttempt> recordedAttempts = [];
  int currentAttemptNumber = 1;
  
  // Target time in milliseconds (for comparison)
  late int targetTimeInMillis;
  
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    
    // Convert target time to milliseconds
    targetTimeInMillis = _convertToMilliseconds(targetTime, targetTimeUnit);
  }
  
  int _convertToMilliseconds(double time, String unit) {
    if (unit == 'minutes') {
      return (time * 60 * 1000).round();
    }
    return (time * 1000).round();
  }
  
  void _startTimer() {
    setState(() {
      _stopwatch.start();
      _isRunning = true;
    });
    
    _updateTimer = Timer.periodic(Duration(milliseconds: 10), (_) {
      if (mounted) {
        setState(() {
          _currentTimeInMillis = _stopwatch.elapsedMilliseconds;
        });
      }
    });
  }
  
  void _stopTimer() {
    setState(() {
      _stopwatch.stop();
      _updateTimer?.cancel();
      _isRunning = false;
      _currentTimeInMillis = _stopwatch.elapsedMilliseconds;
    });
  }
  
  void _resetTimer() {
    setState(() {
      _stopwatch.reset();
      _currentTimeInMillis = 0;
    });
  }
  
  void _recordTime() {
    if (_currentTimeInMillis == 0) return;
    
    final attempt = SpeedAttempt(
      attemptNumber: currentAttemptNumber,
      timeInMilliseconds: _currentTimeInMillis,
      metTarget: _currentTimeInMillis <= targetTimeInMillis,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      recordedAttempts.add(attempt);
      currentAttemptNumber++;
      _resetTimer();
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
```

---

### 5.3 UI Component Design

**Speed Timer Display Widget** (Reusable)

```dart
class SpeedTimerDisplay extends StatelessWidget {
  final int timeInMilliseconds;
  final bool isLarge;
  
  const SpeedTimerDisplay({
    Key? key,
    required this.timeInMilliseconds,
    this.isLarge = true,
  }) : super(key: key);
  
  String _formatTime() {
    final minutes = timeInMilliseconds ~/ 60000;
    final seconds = (timeInMilliseconds % 60000) ~/ 1000;
    final millis = timeInMilliseconds % 1000;
    
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}.'
           '${millis.toString().padLeft(3, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _formatTime(),
        style: TextStyle(
          fontSize: isLarge ? 56 : 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
```

**Start/Stop Toggle Button**

```dart
Widget _buildStartStopButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRunning ? Colors.red : Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      onPressed: _isRunning ? _stopTimer : _startTimer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isRunning ? Icons.stop : Icons.play_arrow,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            _isRunning ? 'STOP TIMER' : 'START TIMER',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
```

```dart
// Just close modal, stay on SpeedTrainingScreen
Navigator.pop(context);
```

**Done**:
```dart
// Save session first
await _saveSession();

// Close modal
Navigator.pop(context);

// Return to skill selection
Navigator.pop(context);
```

---

## 7. Storage Integration

### 7.1 New StorageService Method

**File**: `lib/services/storage_service.dart`

**Method Signature**:
```dart
static Future<void> saveSpeedTrainingSession({
  required String playerName,
  required String playerId,
  required double targetTime,
  required String targetTimeUnit,
  required double distance,
  required String distanceUnit,
  required List<SpeedAttempt> attempts,
}) async {
  // Implementation
}
```

**Implementation**:
```dart
static Future<void> saveSpeedTrainingSession({
  required String playerName,
  required String playerId,
  required double targetTime,
  required String targetTimeUnit,
  required double distance,
  required String distanceUnit,
  required List<SpeedAttempt> attempts,
}) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Load existing sessions
  final sessionsJson = prefs.getString('speed_training_sessions') ?? '{"sessions":[]}';
  final data = json.decode(sessionsJson) as Map<String, dynamic>;
  final sessions = data['sessions'] as List<dynamic>;
  
  // Calculate stats
  final times = attempts.map((a) => a.timeInMilliseconds).toList();
  final bestTime = times.isEmpty ? 0 : times.reduce((a, b) => a < b ? a : b);
  final avgTime = times.isEmpty ? 0.0 : times.reduce((a, b) => a + b) / times.length;
  final metTargetCount = attempts.where((a) => a.metTarget).length;
  final successRate = attempts.isEmpty ? 0.0 : metTargetCount / attempts.length;
  
  // Create new session
  final session = {
    'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
    'playerName': playerName,
    'playerId': playerId,
    'date': DateTime.now().toIso8601String(),
    'targetTime': targetTime,
    'targetTimeUnit': targetTimeUnit,
    'distance': distance,
    'distanceUnit': distanceUnit,
    'attempts': attempts.map((a) => a.toJson()).toList(),
    'bestTime': bestTime,
    'averageTime': avgTime,
    'successRate': successRate,
  };
  
  // Add to sessions list
  sessions.add(session);
  
  // Save back
  final updatedData = {'sessions': sessions};
  await prefs.setString('speed_training_sessions', json.encode(updatedData));
}
```

### 7.2 Loading Speed Sessions (Future)

For viewing saved speed training history (not in current scope, but designed for):

```dart
static Future<List<Map<String, dynamic>>> loadSpeedTrainingSessions({
  String? playerId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionsJson = prefs.getString('speed_training_sessions') ?? '{"sessions":[]}';
  final data = json.decode(sessionsJson) as Map<String, dynamic>;
  final sessions = data['sessions'] as List<dynamic>;
  
  if (playerId != null) {
    return sessions
        .where((s) => s['playerId'] == playerId)
        .cast<Map<String, dynamic>>()
        .toList();
  }
  
  return sessions.cast<Map<String, dynamic>>();
}
```

---

## 8. UI Component Details

### 8.1 Timer Display Widget

**Component**: `_TimerDisplay`

```dart
class _TimerDisplay extends StatelessWidget {
  final int elapsedMilliseconds;
  
  const _TimerDisplay({required this.elapsedMilliseconds});
  
  @override
  Widget build(BuildContext context) {
    final minutes = (elapsedMilliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((elapsedMilliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (elapsedMilliseconds % 1000).toString().padLeft(3, '0');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Text(
        '$minutes:$seconds.$millis',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
```

### 8.2 Control Buttons

**Start/Stop Button** (Primary action):
```dart
Widget _buildStartStopButton() {
  return SizedBox(
    width: double.infinity,
    height: 80,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunning ? Colors.red.shade600 : Colors.green.shade600,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      onPressed: isRunning ? _stopTimer : _startTimer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRunning ? Icons.stop_circle : Icons.play_circle,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            isRunning ? 'STOP TIMER' : 'START TIMER',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Secondary Buttons** (Reset, Record):
```dart
Widget _buildSecondaryButtons() {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: canReset ? _resetTimer : null,
          child: const Text('Reset'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: canRecordTime ? _recordTime : null,
          child: const Text(
            'Record Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
```

### 8.3 Attempts List

```dart
Widget _buildAttemptsList() {
  if (_attempts.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No attempts recorded yet.\nStart the timer and record your first sprint!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _attempts.length,
    itemBuilder: (context, index) {
      final attempt = _attempts[index];
      final targetInMs = _getTargetInMilliseconds();
      final diff = attempt.timeInMilliseconds - targetInMs;
      final diffSeconds = (diff.abs() / 1000).toStringAsFixed(3);
      final diffText = diff > 0 ? '+$diffSeconds' : '-$diffSeconds';
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: attempt.metTarget 
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: attempt.metTarget 
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: attempt.metTarget ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${attempt.attemptNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attempt.formattedTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${diffText}s ${attempt.metTarget ? "under" : "over"} target',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              attempt.metTarget ? Icons.check_circle : Icons.cancel,
              color: attempt.metTarget ? Colors.green : Colors.red,
              size: 24,
            ),
          ],
        ),
      );
    },
  );
}
```

---

## 9. File Structure & Changes

### 9.1 New Files

```
lib/features/training/technical/
├── models/
│   └── speed_attempt.dart                    (NEW - 80 lines)
├── screens/
│   └── speed_training_screen.dart            (NEW - 450 lines)
└── widgets/
    ├── speed_timer_display.dart              (NEW - 60 lines)
    └── speed_config_dialog.dart              (NEW - 150 lines)
```

### 9.2 Modified Files

```
lib/features/training/technical/screens/
└── skill_setup_screen.dart                   (MODIFY - add ~50 lines)
    - Add _showSpeedConfigDialog() method
    - Add speed detection in _startTraining()
    - Add navigation to SpeedTrainingScreen

lib/services/
└── storage_service.dart                      (MODIFY - add ~80 lines)
    - Add saveSpeedTrainingSession() method
    - Add loadSpeedTrainingSessions() method
```

### 9.3 No Changes Needed

- `technical_skill.dart` - Reuses existing fields
- `training_entry.dart` - Compatible storage structure
- `technical_screen.dart` - Unchanged (other skills)
- Other technical training screens - Unchanged

---

## 10. Implementation Phases

### Phase 1: Data Models (Day 1)
**Tasks**:
1. Create `speed_attempt.dart` model
2. Add helper methods (formattedTime, toJson, fromJson)
3. Write unit tests for SpeedAttempt

**Deliverable**: SpeedAttempt model with tests

---

### Phase 2: Storage Layer (Day 1-2)
**Tasks**:
1. Add `saveSpeedTrainingSession()` to StorageService
2. Add `loadSpeedTrainingSessions()` to StorageService
3. Test save/load with mock data

**Deliverable**: Storage methods functional and tested

---

### Phase 3: Config Dialog (Day 2)
**Tasks**:
1. Create `speed_config_dialog.dart` widget
2. Add time unit dropdown (seconds/minutes)
3. Add distance unit dropdown (meters/yards)
4. Add validation logic
5. Test dialog UI and validation

**Deliverable**: Functional configuration dialog

---

### Phase 4: Speed Training Screen - Core (Day 3-4)
**Tasks**:
1. Create `speed_training_screen.dart` scaffold
2. Implement timer logic (Stopwatch + Timer.periodic)
3. Create timer display widget
4. Add Start/Stop/Reset buttons
5. Test timer accuracy and UI updates

**Deliverable**: Working timer interface

---

### Phase 5: Speed Training Screen - Recording (Day 4-5)
**Tasks**:
1. Implement "Record Time" functionality
2. Build attempts list UI
3. Add attempt cards with formatting
4. Test recording multiple attempts
5. Test edge cases (0ms, very long times)

**Deliverable**: Full attempt recording system

---

### Phase 6: Summary & Integration (Day 5-6)
**Tasks**:
1. Create summary modal dialog
2. Calculate stats (best, average, success rate)
3. Integrate with StorageService save
4. Modify `skill_setup_screen.dart` for Speed detection
5. Add navigation to SpeedTrainingScreen
6. End-to-end testing

**Deliverable**: Complete Speed timer feature

---

### Phase 7: Polish & Testing (Day 6-7)
**Tasks**:
1. UI polish (colors, spacing, animations)
2. Add loading states
3. Add error handling
4. Test on multiple devices
5. Test with different configurations
6. Manual QA against requirements

**Deliverable**: Production-ready feature

---

## 11. Testing Strategy

### 11.1 Unit Tests

**SpeedAttempt Model**:
- Test formattedTime for various durations
- Test toJson/fromJson serialization
- Test metTarget calculation

**Timer Logic**:
- Mock Stopwatch behavior
- Test start/stop/reset sequences
- Test elapsed time calculations

### 11.2 Widget Tests

**SpeedConfigDialog**:
- Test validation (negative values, zero)
- Test unit dropdowns
- Test confirm button enabled state

**SpeedTrainingScreen**:
- Test timer display updates
- Test button enabled/disabled states
- Test attempt recording
- Test attempts list rendering

### 11.3 Integration Tests

**End-to-End Flow**:
1. Select Speed skill
2. Configure (15 sec, 100m)
3. Start timer
4. Stop at ~10 seconds
5. Record time
6. Repeat 2 more times
7. Complete training
8. Verify summary
9. Save session
10. Verify storage

### 11.4 Manual Testing

**Device Testing**:
- Test on small screen (360x640)
- Test on large screen (tablet)
- Test timer accuracy over 60 seconds
- Test rapid button taps
- Test app backgrounding (timer should stop)

---

## 12. Performance Considerations

### 12.1 Timer Update Frequency

**Decision**: Update every 10ms

**Rationale**:
- Smooth millisecond display (100 FPS)
- Low CPU overhead (Timer.periodic is efficient)
- Acceptable battery drain for short sessions

**Alternative considered**: 16ms (60 FPS) - too choppy for milliseconds

### 12.2 Memory Management

**Stopwatch instance**: Single instance, reused across attempts
**Timer.periodic**: Properly canceled in dispose()
**Attempts list**: Stored in memory during session, persisted on save

**Max attempts estimate**: 20 attempts × 100 bytes = 2KB in memory (negligible)

### 12.3 UI Performance

**ListView.builder**: Used for attempts list (efficient for scrolling)
**setState() scope**: Only updates timer display, not entire screen
**No expensive operations**: All calculations are simple arithmetic

---

## 13. Edge Cases & Error Handling

### 13.1 Edge Cases

**Case 1: Timer at 0ms when Record Time pressed**
- **Handling**: Button disabled (canRecordTime = false)

**Case 2: User closes app during timing**
- **Handling**: Timer stops, data lost (documented behavior)
- **Future**: Could save incomplete session

**Case 3: Very long time (>60 minutes)**
- **Handling**: Timer displays correctly (MM:SS.mmm handles it)

**Case 4: Device goes to sleep**
- **Handling**: Stopwatch pauses (Dart behavior), matches UI

**Case 5: No attempts recorded, user taps Complete Training**
- **Handling**: Show dialog "No attempts recorded. Record at least one attempt to save session."

### 13.2 Validation

**Configuration**:
- Target time must be > 0
- Distance must be > 0
- Show SnackBar with error message

**Recording**:
- Cannot record if timer is running
- Cannot record if timer is at 0ms

### 13.3 Error Recovery

**Storage failure**:
```dart
try {
  await StorageService.saveSpeedTrainingSession(...);
  // Show success
} catch (e) {
  // Show error dialog with retry option
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to save session: $e'),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: _saveSession,
      ),
    ),
  );
}
```

---

## 14. Future Enhancements

**Not in current scope, but designed for**:

1. **Audio Cues**: Beep on start/stop
2. **Haptic Feedback**: Vibrate on button press
3. **Background Timer**: Continue timing when app backgrounded
4. **GPS Integration**: Auto-measure distance
5. **Comparison View**: Compare with previous sessions
6. **Export to Excel**: Include speed sessions in exports
7. **Charts**: Visualize speed progress over time
8. **Split Times**: Record intermediate lap times
9. **Voice Commands**: "Start", "Stop", "Record"
10. **Apple Watch / Wear OS**: Companion timer app

---

## 15. Dependencies

### 15.1 Flutter Packages

**Current (No new dependencies needed)**:
- `dart:async` - Timer, Stopwatch
- `flutter/material.dart` - UI widgets
- `shared_preferences` - Storage (already used)

**Optional (Future)**:
- `audioplayers` - For audio cues
- `vibration` - For haptic feedback
- `geolocator` - For GPS tracking

### 15.2 Platform Requirements

- **Minimum SDK**: Android API 21+ / iOS 11+
- **Permissions**: None required for basic timer
- **Storage**: ~10KB per 100 sessions

---

## 16. Migration & Rollout

### 16.1 Data Migration

**No migration needed**:
- New Speed data uses separate storage key
- Old technical training data unaffected
- Existing Speed skill data (if any) remains in old format

### 16.2 Feature Flag (Optional)

For gradual rollout, could add:
```dart
const bool ENABLE_SPEED_TIMER = true;

if (ENABLE_SPEED_TIMER && skill.key == 'speed') {
  // New timer flow
} else {
  // Old button flow
}
```

### 16.3 User Communication

**In-app tooltip** on first Speed skill selection:
```
"⚡ Speed skill now uses a timer!
Record precise sprint times with 
millisecond accuracy."
```

---

## 17. Success Metrics

### 17.1 Functional Metrics

- ✅ Timer accuracy: Within ±50ms of actual time
- ✅ UI update rate: Smooth 10ms updates
- ✅ Save success rate: 99%+ sessions saved successfully
- ✅ Zero crashes related to timer logic

### 17.2 Usability Metrics

- ✅ Users can configure Speed training in <30 seconds
- ✅ Users can record 3 attempts in <2 minutes
- ✅ Timer display is readable from 2 meters away
- ✅ Buttons are easily tappable (48x48dp minimum)

### 17.3 Acceptance Criteria

From requirements.md - all test cases must pass:
- ✅ Test Case 1: Configure Speed Training
- ✅ Test Case 2: Record Single Sprint
- ✅ Test Case 3: Multiple Attempts with Unlimited Recording
- ✅ Test Case 4: Record Additional Attempt from Summary
- ✅ Test Case 5: Data Persistence

---

## 18. Appendix

### A. Color Scheme

Using existing app theme colors:
- **Primary**: `Theme.of(context).colorScheme.primary`
- **Green** (Start, Success): `Colors.green.shade600`
- **Red** (Stop, Failure): `Colors.red.shade600`
- **Blue** (Record): `Colors.blue.shade600`
- **Surface**: `Theme.of(context).colorScheme.surfaceContainerHigh`

### B. Typography

- **Timer Display**: 56sp, Bold, Monospace
- **Attempt Times**: 18sp, Bold, Monospace
- **Button Text**: 16-20sp, Bold
- **Body Text**: 14sp, Regular

### C. Spacing

- **Card Padding**: 16-20dp
- **Button Height**: 48-80dp
- **Section Spacing**: 24-32dp
- **List Item Spacing**: 8-12dp

---

**End of Design Document**

**Next Steps**: Review design → Create tasks.md → Begin implementation
