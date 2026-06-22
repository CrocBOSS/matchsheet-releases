import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_entry.dart';
import '../core/models/stat_type.dart';
import '../features/training/models/training_entry.dart';

class StorageService {
  static const String _playersKey = 'players_data';
  static const String _nextIdKey = 'next_player_id';
  static const String _statTypesKey = 'stat_types';
  static const String _positionsKey = 'positions';
  static const String UNSAVED_MATCH_NAME = '__UNSAVED_MATCH__';

  static List<StatType> getDefaultStatTypes() {
    return [
      StatType(key: 'completedPasses', label: 'Passes'),
      StatType(key: 'interceptions', label: 'Intercep'),
      StatType(key: 'turnovers', label: 'Turnover'),
      StatType(key: 'tackles', label: 'Tackles'),
      StatType(key: 'fouls', label: 'Fouls'),
      StatType(key: 'shotsOnTarget', label: 'Shots'),
      StatType(key: 'assists', label: 'Assists'),
      StatType(key: 'goals', label: 'Goals'),
      StatType(key: 'goalkeeperSaves', label: 'GK Saves'),
      StatType(key: 'yellowCards', label: 'YC'),
    ];
  }

  /// Default positions for players
  static List<StatType> getDefaultPositions() {
    return [
      StatType(key: 'GK', label: 'GK'),
      StatType(key: 'LB', label: 'LB'),
      StatType(key: 'RB', label: 'RB'),
      StatType(key: 'CB', label: 'CB'),
      StatType(key: 'AMF', label: 'AMF'),
      StatType(key: 'DMF', label: 'DMF'),
      StatType(key: 'LWF', label: 'LWF'),
      StatType(key: 'RWF', label: 'RWF'),
      StatType(key: 'SS', label: 'SS'),
      StatType(key: 'CF', label: 'CF'),
    ];
  }

  /// Default stat types for Basketball
  static List<StatType> getDefaultBasketballStatTypes() {
    return [
      StatType(key: 'twoPointAttempts', label: '2PT Attempts'),
      StatType(key: 'twoPointMade', label: '2PT Made'),
      StatType(key: 'threePointAttempts', label: '3PT Attempts'),
      StatType(key: 'threePointMade', label: '3PT Made'),
      StatType(key: 'freeThrowAttempts', label: 'FT Attempts'),
      StatType(key: 'freeThrowMade', label: 'FT Made'),
      StatType(key: 'rebounds', label: 'Rebounds'),
      StatType(key: 'turnovers', label: 'Turnovers'),
      StatType(key: 'assists', label: 'Assists'),
      StatType(key: 'steals', label: 'Steals'),
      StatType(key: 'blocks', label: 'Blocks'),
      StatType(key: 'fouls', label: 'Fouls'),
    ];
  }

  /// Default positions for Basketball players
  static List<StatType> getDefaultBasketballPositions() {
    return [
      StatType(key: 'Point Guard', label: 'PG'),
      StatType(key: 'Shooting Guard', label: 'SG'),
      StatType(key: 'Small Forward', label: 'SF'),
      StatType(key: 'Power Forward', label: 'PF'),
      StatType(key: 'Center', label: 'C'),
    ];
  }

  /// Parse session data into players, statTypes, and nextId
  static (List<Player>, List<StatType>, int) parseSessionData(Map<String, dynamic> sessionData) {
    // Convert players from JSON
    final playersData = (sessionData['players'] as List<dynamic>)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();
    
    // Convert stat types from JSON
    final statTypesData = (sessionData['statTypes'] as List<dynamic>)
        .map((s) => StatType(
              key: s['key'] as String,
              label: s['label'] as String,
            ))
        .toList();
    
    final nextId = sessionData['nextId'] as int;
    
    return (playersData, statTypesData, nextId);
  }

  /// Save all players to persistent storage
  static Future<void> savePlayers(List<Player> players, int nextId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert players to JSON
      final playersJson = players.map((p) => p.toJson()).toList();
      
      // Save players list
      await prefs.setString(_playersKey, jsonEncode(playersJson));
      
      // Save next ID
      await prefs.setInt(_nextIdKey, nextId);
    } catch (e) {
      // Error saving players silently
    }
  }

  /// Load all players from persistent storage
  static Future<Map<String, dynamic>> loadPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final playersJsonString = prefs.getString(_playersKey);
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      
      if (playersJsonString == null || playersJsonString.isEmpty) {
        return {'players': [], 'nextId': 1};
      }
      
      // Decode JSON
      final List<dynamic> playersJson = jsonDecode(playersJsonString);
      
      // Convert to Player objects
      final players = playersJson
          .map((json) => Player.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return {'players': players, 'nextId': nextId};
    } catch (e) {
      return {'players': [], 'nextId': 1};
    }
  }

  /// Clear all saved data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playersKey);
      await prefs.remove(_nextIdKey);
    } catch (e) {
      // Error clearing data silently
    }
  }

  /// Save stat types
  static Future<void> saveStatTypes(List<StatType> statTypes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statTypesJson = statTypes.map((s) => s.toJson()).toList();
      await prefs.setString(_statTypesKey, jsonEncode(statTypesJson));
    } catch (e) {
      // Error saving stat types silently
    }
  }

  /// Load stat types or return defaults
  static Future<List<StatType>> loadStatTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statTypesString = prefs.getString(_statTypesKey);
      
      if (statTypesString == null || statTypesString.isEmpty) {
        return getDefaultStatTypes();
      }
      
      final List<dynamic> statTypesJson = jsonDecode(statTypesString);
      final savedStatTypes = statTypesJson
          .map((json) => StatType.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Get default stat types to check for new ones
      final defaultStatTypes = getDefaultStatTypes();
      final defaultKeys = defaultStatTypes.map((s) => s.key).toSet();
      final savedKeys = savedStatTypes.map((s) => s.key).toSet();
      
      // Find new defaults that aren't in saved list
      final newDefaults = defaultKeys.difference(savedKeys);
      
      // If there are new defaults, add them to the saved list and save
      if (newDefaults.isNotEmpty) {
        final newStatTypes = List<StatType>.from(savedStatTypes);
        for (final key in newDefaults) {
          final defaultStat = defaultStatTypes.firstWhere((s) => s.key == key);
          newStatTypes.add(defaultStat);
        }
        // Save the updated list
        await saveStatTypes(newStatTypes);
        return newStatTypes;
      }
      
      return savedStatTypes;
    } catch (e) {
      return getDefaultStatTypes();
    }
  }

  /// Save positions
  static Future<void> savePositions(List<StatType> positions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsJson = positions.map((p) => p.toJson()).toList();
      await prefs.setString(_positionsKey, jsonEncode(positionsJson));
    } catch (e) {
      // Error saving positions silently
    }
  }

  /// Load positions or return defaults
  static Future<List<StatType>> loadPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsString = prefs.getString(_positionsKey);
      
      if (positionsString == null || positionsString.isEmpty) {
        return getDefaultPositions();
      }
      
      final List<dynamic> positionsJson = jsonDecode(positionsString);
      return positionsJson
          .map((json) => StatType.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return getDefaultPositions();
    }
  }

  /// Parse players from text format (jersey,name)
  static (List<Map<String, dynamic>>, String) parsePlayersFromText(String content) {
    final lines = content.split('\n');
    final players = <Map<String, dynamic>>[];
    int nextId = 1;
    String teamName = 'Team A';
    int startLine = 0;

    // Check if first line is team name (no comma)
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
      if (firstLine.isNotEmpty && !firstLine.contains(',')) {
        // First line is team name
        teamName = firstLine;
        startLine = 1;
      }
    }

    // Parse player lines
    for (int i = startLine; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        try {
          final number = int.parse(parts[0].trim());
          final name = parts.sublist(1).join(',').trim();
          
          if (name.isNotEmpty) {
            players.add({
              'id': nextId++,
              'number': number,
              'name': name,
            });
          }
        } catch (e) {
          // Error parsing line silently
        }
      }
    }

    return (players, teamName);
  }

  /// Save current game session with a name
  static Future<void> saveGameSession(String sessionName, List<Player> players, List<StatType> statTypes, int nextId, {String teamName = 'Team A', String sport = 'soccer'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create session data
      final sessionData = {
        'name': sessionName,
        'timestamp': DateTime.now().toIso8601String(),
        'teamName': teamName,
        'sport': sport,
        'players': players.map((p) => p.toJson()).toList(),
        'statTypes': statTypes.map((s) => {'key': s.key, 'label': s.label}).toList(),
        'nextId': nextId,
      };
      
      // Get existing saved games list
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      // Check if a session with this name already exists (and same sport)
      final existingIndex = savedGames.indexWhere((s) => s['name'] == sessionName && (s['sport'] ?? 'soccer') == sport);
      
      if (existingIndex >= 0) {
        // Update existing session
        savedGames[existingIndex] = sessionData;
      } else {
        // Add new session
        savedGames.add(sessionData);
      }
      
      // Save back
      await prefs.setString('saved_games', jsonEncode(savedGames));
    } catch (e) {
      // Error saving game session silently
    }
  }

  /// Load all saved game sessions filtered by sport
  static Future<List<Map<String, dynamic>>> loadSavedSessions({String? sport}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      if (sport == null) {
        return savedGames.cast<Map<String, dynamic>>();
      }
      
      // Filter by sport
      return savedGames
          .cast<Map<String, dynamic>>()
          .where((game) => (game['sport'] ?? 'soccer') == sport)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a specific saved session
  static Future<Map<String, dynamic>?> getSession(int index) async {
    try {
      final sessions = await loadSavedSessions();
      if (index >= 0 && index < sessions.length) {
        return sessions[index];
      }
    } catch (e) {
      // Error getting session silently
    }
    return null;
  }

  /// Delete a saved session
  static Future<void> deleteSession(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      if (index >= 0 && index < savedGames.length) {
        savedGames.removeAt(index);
        await prefs.setString('saved_games', jsonEncode(savedGames));
      }
    } catch (e) {
      // Error deleting session silently
    }
  }

  /// Check if an unsaved match exists
  static Future<bool> hasUnsavedMatch() async {
    try {
      final sessions = await loadSavedSessions();
      return sessions.any((s) => s['name'] == UNSAVED_MATCH_NAME);
    } catch (e) {
      return false;
    }
  }

  /// Get the unsaved match session
  static Future<Map<String, dynamic>?> getUnsavedMatch() async {
    try {
      final sessions = await loadSavedSessions();
      final index = sessions.indexWhere((s) => s['name'] == UNSAVED_MATCH_NAME);
      if (index >= 0) {
        return sessions[index];
      }
    } catch (e) {
      // Error getting unsaved match silently
    }
    return null;
  }

  /// Rename unsaved match to a new name
  static Future<void> renameUnsavedMatch(String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      final index = savedGames.indexWhere((s) => s['name'] == UNSAVED_MATCH_NAME);
      if (index >= 0) {
        final unsavedGame = savedGames[index] as Map<String, dynamic>;
        unsavedGame['name'] = newName;
        await prefs.setString('saved_games', jsonEncode(savedGames));
      }
    } catch (e) {
      // Error renaming unsaved match silently
    }
  }

  /// Delete unsaved match
  static Future<void> deleteUnsavedMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      final index = savedGames.indexWhere((s) => s['name'] == UNSAVED_MATCH_NAME);
      if (index >= 0) {
        savedGames.removeAt(index);
        await prefs.setString('saved_games', jsonEncode(savedGames));
      }
    } catch (e) {
      // Error deleting unsaved match silently
    }
  }

  /// Save training entries separately from match data
  static Future<void> saveTrainingEntries(
    List<TrainingEntry> entries,
    int nextId,
    String trainingType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'training_entries_$trainingType';
      final nextIdKey = 'training_next_id_$trainingType';

      // Convert entries to JSON
      final entriesJson = entries.map((e) => e.toJson()).toList();

      // Save entries list
      await prefs.setString(key, jsonEncode(entriesJson));

      // Save next ID
      await prefs.setInt(nextIdKey, nextId);
    } catch (e) {
      // Error saving training entries silently
    }
  }

  /// Load training entries from persistent storage
  static Future<Map<String, dynamic>> loadTrainingEntries(String trainingType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'training_entries_$trainingType';
      final nextIdKey = 'training_next_id_$trainingType';

      final entriesJsonString = prefs.getString(key);
      final nextId = prefs.getInt(nextIdKey) ?? 1;

      if (entriesJsonString == null || entriesJsonString.isEmpty) {
        return {'entries': [], 'nextId': 1};
      }

      // Decode JSON
      final List<dynamic> entriesJson = jsonDecode(entriesJsonString);

      // Convert to TrainingEntry objects
      final entries = entriesJson
          .map((json) => TrainingEntry.fromJson(json as Map<String, dynamic>))
          .toList();

      return {'entries': entries, 'nextId': nextId};
    } catch (e) {
      return {'entries': [], 'nextId': 1};
    }
  }

  /// Clear training data for a specific training type
  static Future<void> clearTrainingData(String trainingType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'training_entries_$trainingType';
      final nextIdKey = 'training_next_id_$trainingType';
      await prefs.remove(key);
      await prefs.remove(nextIdKey);
    } catch (e) {
      // Error clearing training data silently
    }
  }

  /// Default strength exercises
  static List<Map<String, dynamic>> getDefaultStrengthExercises() {
    return [
      {
        'key': 'calfRises',
        'label': 'Calf Rises',
        'targetReps': 120,
        'targetSets': 1,
        'isPerLeg': true,
        'unit': 'reps',
      },
      {
        'key': 'pickUps',
        'label': 'Pick Ups',
        'targetReps': 150,
        'targetSets': 1,
        'isPerLeg': false,
        'unit': 'reps',
      },
      {
        'key': 'crabWalk',
        'label': 'Crab Walk',
        'targetReps': 100,
        'targetSets': 2,
        'isPerLeg': false,
        'unit': 'meters',
      },
      {
        'key': 'sitUps',
        'label': 'Sit Ups',
        'targetReps': 25,
        'targetSets': 5,
        'isPerLeg': false,
        'unit': 'reps',
      },
      {
        'key': 'pushUps',
        'label': 'Push Ups',
        'targetReps': 25,
        'targetSets': 5,
        'isPerLeg': false,
        'unit': 'reps',
      },
      {
        'key': 'barrierJumps',
        'label': 'Barrier Jumps',
        'targetReps': 10,
        'targetSets': 5,
        'isPerLeg': false,
        'unit': 'reps',
      },
    ];
  }

  /// Save strength exercises to persistent storage
  static Future<void> saveStrengthExercises(List<Map<String, dynamic>> exercises) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = exercises;
      await prefs.setString('strength_exercises', jsonEncode(exercisesJson));
    } catch (e) {
      // Error saving exercises silently
    }
  }

  /// Load strength exercises or return defaults
  static Future<List<Map<String, dynamic>>> loadStrengthExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesString = prefs.getString('strength_exercises');

      if (exercisesString == null || exercisesString.isEmpty) {
        return getDefaultStrengthExercises();
      }

      final List<dynamic> exercisesJson = jsonDecode(exercisesString);
      return exercisesJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return getDefaultStrengthExercises();
    }
  }

  /// Default technical skills for performance tracking
  static List<Map<String, dynamic>> getDefaultTechnicalSkills() {
    return [
      {
        'key': 'skillsAndComposure',
        'label': 'Skills and Composure',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'aggression',
        'label': 'Aggression',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'longThrows',
        'label': 'Long Throws',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'distributionAccuracy',
        'label': 'Distribution Accuracy',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'weakFoot',
        'label': 'Weak Foot',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'scanningAwareness',
        'label': 'Scanning and Awareness',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'targetPractice',
        'label': 'Target Practice',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'defensiveHeader',
        'label': 'Defensive Header',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'followUpBalls',
        'label': 'Follow up balls',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'throughPasses',
        'label': 'Through passes',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'lineDominance',
        'label': 'Line Dominance',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'speed',
        'label': 'Speed',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'longPasses',
        'label': 'Long Passes',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'firstTouch',
        'label': 'First Touch',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'killerInstinct',
        'label': 'Killer Instinct',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'communication',
        'label': 'Communication',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'overConfidence',
        'label': 'Over Confidence',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'oneVOneSituations',
        'label': '1v1 Situations',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'agility',
        'label': 'Agility',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'turning',
        'label': 'Turning',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'shooting',
        'label': 'Shooting',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'crossing',
        'label': 'Crossing',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'volleyShots',
        'label': 'Volley shots',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'positioning',
        'label': 'Positioning',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
      {
        'key': 'defensiveMindset',
        'label': 'Defensive Mindset',
        'targetScore': 5,
        'totalReps': 10,
        'unit': 'reps',
      },
    ];
  }

  static Future<void> saveTechnicalSkills(List<Map<String, dynamic>> skills) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('technical_skills', jsonEncode(skills));
    } catch (e) {
      // Error saving skills silently
    }
  }

  static Future<List<Map<String, dynamic>>> loadTechnicalSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skillsString = prefs.getString('technical_skills');

      if (skillsString == null || skillsString.isEmpty) {
        return getDefaultTechnicalSkills();
      }

      final List<dynamic> skillsJson = jsonDecode(skillsString);
      return skillsJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return getDefaultTechnicalSkills();
    }
  }

  /// Save strength training session with name and timestamp
  static Future<void> saveStrengthTrainingSession(
    String sessionName,
    List<TrainingEntry> entries,
    int nextId, {
    String playerId = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = DateTime.now().microsecondsSinceEpoch.toString();

      // Create session data with structured strength training detail
      final sessionData = {
        'sessionId': sessionId,
        'name': sessionName,
        'timestamp': DateTime.now().toIso8601String(),
        'sport': 'strength_condition',
        'entries': entries.map((e) => e.toJson()).toList(),
        'structuredEntries': entries.map(_buildStructuredStrengthEntry).toList(),
        'nextId': nextId,
        'playerId': playerId,
      };

      // Get existing saved sessions list
      final savedSessionsJson = prefs.getString('saved_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      // Add new session (allow duplicate names with different timestamps)
      savedSessions.add(sessionData);

      // Save back
      await prefs.setString('saved_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error saving strength training session silently
    }
  }

  static Map<String, dynamic> _buildStructuredStrengthEntry(TrainingEntry entry) {
    final groupedExercises = <String, Map<String, Map<int, int>>>{};

    for (final stat in entry.customStats.entries) {
      final match = RegExp(r'^(.*?)(?:_left)?_set(\d+)$').firstMatch(stat.key);      if (match == null) {
        continue;
      }

      final exerciseKey = match.group(1)!;
      final setNumber = int.tryParse(match.group(2)!) ?? 0;
      final isLeftLeg = stat.key.contains('_left_set');
      final legKey = isLeftLeg ? 'left' : 'right';

      groupedExercises.putIfAbsent(exerciseKey, () => <String, Map<int, int>>{});
      groupedExercises[exerciseKey]!.putIfAbsent(legKey, () => <int, int>{});
      groupedExercises[exerciseKey]![legKey]![setNumber] = stat.value is int ? stat.value as int : int.tryParse('${stat.value}') ?? 0;
    }

    final exercises = <Map<String, dynamic>>[];
    for (final exerciseEntry in groupedExercises.entries) {
      final exerciseKey = exerciseEntry.key;
      final legs = exerciseEntry.value;
      final isPerLeg = legs.length > 1 || legs.containsKey('left');
      final exerciseLabel = _formatExerciseLabel(exerciseKey);
      final unit = _getExerciseUnit(exerciseKey);

      if (isPerLeg) {
        final leftSets = legs['left']?.entries.map((e) => {
              'set': e.key,
              'reps': e.value,
            }).toList() ?? [];
        final rightSets = legs['right']?.entries.map((e) => {
              'set': e.key,
              'reps': e.value,
            }).toList() ?? [];

        exercises.add({
          'exerciseKey': exerciseKey,
          'exerciseLabel': exerciseLabel,
          'isPerLeg': true,
          'unit': unit,
          'legs': {
            'left': leftSets,
            'right': rightSets,
          },
        });
      } else {
        final sets = legs['right']?.entries.map((e) => {
              'set': e.key,
              'reps': e.value,
            }).toList() ?? [];

        exercises.add({
          'exerciseKey': exerciseKey,
          'exerciseLabel': exerciseLabel,
          'isPerLeg': false,
          'unit': unit,
          'sets': sets,
        });
      }
    }

    return {
      'entryId': entry.id,
      'playerId': entry.playerId,
      'playerNumber': entry.playerNumber,
      'playerName': entry.playerName,
      'position': entry.position,
      'trainingType': entry.trainingType,
      'notes': entry.notes,
      'date': entry.date.toIso8601String(),
      'customStats': entry.customStats,
      'exercises': exercises,
    };
  }

  static Map<String, dynamic> _buildStructuredTechnicalEntry(
    String skillKey,
    String skillLabel,
    int successful,
    int neutral,
    int fail,
    double currentScore,
    double? targetScore,
    int? totalReps,
  ) {
    return {
      'skillKey': skillKey,
      'skillLabel': skillLabel,
      'attempts': {
        'successful': successful,
        'neutral': neutral,
        'fail': fail,
        'total': successful + neutral + fail,
      },
      'currentScore': currentScore,
      'targetScore': targetScore,
      'totalReps': totalReps,
    };
  }

  static String _formatExerciseLabel(String key) {
    final label = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    final cleaned = label.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    return cleaned
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String _getExerciseUnit(String exerciseKey) {
    if (exerciseKey == 'crabWalk') {
      return 'done';
    }
    return 'reps';
  }

  /// Load saved strength training sessions, optionally filtered by playerId
  static Future<List<Map<String, dynamic>>> loadSavedStrengthTrainingSessions({String? playerId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      List<Map<String, dynamic>> sessions = savedSessions.cast<Map<String, dynamic>>();
      
      // Filter by playerId if provided
      if (playerId != null) {
        sessions = sessions.where((session) {
          final sessionPlayerId = session['playerId'] as String? ?? '';
          return sessionPlayerId == playerId;
        }).toList();
      }
      
      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// Save technical skill training session
  static Future<void> saveTechnicalTrainingSession(
    String sessionName,
    String skillKey,
    String skillLabel,
    int successful,
    int neutral,
    int fail,
    double currentScore, {
    String playerId = '',
    String playerNumber = '',
    String playerName = '',
    double? targetScore,
    int? totalReps,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = DateTime.now().microsecondsSinceEpoch.toString();

      // Create session data with structured technical skill details
      final sessionData = {
        'sessionId': sessionId,
        'name': sessionName,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'technical_skill',
        'skillKey': skillKey,
        'skillLabel': skillLabel,
        'successful': successful,
        'neutral': neutral,
        'fail': fail,
        'currentScore': currentScore,
        'playerId': playerId,
        'playerNumber': playerNumber,
        'playerName': playerName,
        'targetScore': targetScore,
        'totalReps': totalReps,
        'structuredData': _buildStructuredTechnicalEntry(
          skillKey,
          skillLabel,
          successful,
          neutral,
          fail,
          currentScore,
          targetScore,
          totalReps,
        ),
      };

      // Get existing saved sessions list
      final savedSessionsJson = prefs.getString('saved_technical_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      // Add new session
      savedSessions.add(sessionData);

      // Save back
      await prefs.setString('saved_technical_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error saving technical training session silently
    }
  }

  /// Load saved technical training sessions, optionally filtered by playerId
  static Future<List<Map<String, dynamic>>> loadSavedTechnicalTrainingSessions({String? playerId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_technical_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      List<Map<String, dynamic>> sessions = savedSessions.cast<Map<String, dynamic>>();
      
      // Filter by playerId if provided
      if (playerId != null) {
        sessions = sessions.where((session) {
          final sessionPlayerId = session['playerId'] as String? ?? '';
          return sessionPlayerId == playerId;
        }).toList();
      }
      
      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// Delete technical training session
  static Future<void> deleteTechnicalTrainingSession(
    int index, {
    String? playerId,
    String? sessionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_technical_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      if (sessionId != null && sessionId.isNotEmpty) {
        for (int i = 0; i < savedSessions.length; i++) {
          final session = savedSessions[i] as Map<String, dynamic>;
          if ((session['sessionId'] as String?) == sessionId) {
            savedSessions.removeAt(i);
            break;
          }
        }
      } else if (playerId != null) {
        // Find and delete the index-th session belonging to this player
        int playerSessionCount = 0;
        for (int i = 0; i < savedSessions.length; i++) {
          final session = savedSessions[i] as Map<String, dynamic>;
          final sessionPlayerId = session['playerId'] as String? ?? '';
          if (sessionPlayerId == playerId) {
            if (playerSessionCount == index) {
              savedSessions.removeAt(i);
              break;
            }
            playerSessionCount++;
          }
        }
      } else if (index >= 0 && index < savedSessions.length) {
        // Delete by global index (legacy behavior)
        savedSessions.removeAt(index);
      }
      
      await prefs.setString('saved_technical_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error deleting technical training session silently
    }
  }

  /// Delete a saved strength training session by index
  static Future<void> deleteStrengthTrainingSession(
    int index, {
    String? playerId,
    String? sessionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);

      if (sessionId != null && sessionId.isNotEmpty) {
        for (int i = 0; i < savedSessions.length; i++) {
          final session = savedSessions[i] as Map<String, dynamic>;
          if ((session['sessionId'] as String?) == sessionId) {
            savedSessions.removeAt(i);
            break;
          }
        }
      } else if (playerId != null) {
        // Find and delete the index-th session belonging to this player
        int playerSessionCount = 0;
        for (int i = 0; i < savedSessions.length; i++) {
          final session = savedSessions[i] as Map<String, dynamic>;
          final sessionPlayerId = session['playerId'] as String? ?? '';
          if (sessionPlayerId == playerId) {
            if (playerSessionCount == index) {
              savedSessions.removeAt(i);
              break;
            }
            playerSessionCount++;
          }
        }
      } else if (index >= 0 && index < savedSessions.length) {
        // Delete by global index (legacy behavior)
        savedSessions.removeAt(index);
      }
      
      await prefs.setString('saved_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error deleting strength training session silently
    }
  }

  // ==================== TRAINING PLAYER MANAGEMENT ====================

  static const String _trainingPlayersKey = 'training_players';
  static const String _activeTrainingPlayerKey = 'active_training_player_id';

  /// Save a list of training players
  static Future<void> saveTrainingPlayers(List<dynamic> players) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playersJson = players.map((p) => p.toJson()).toList();
      await prefs.setString(_trainingPlayersKey, jsonEncode(playersJson));
    } catch (e) {
      // Error saving training players silently
    }
  }

  /// Load all training players
  static Future<List<dynamic>> loadTrainingPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playersJsonString = prefs.getString(_trainingPlayersKey);

      if (playersJsonString == null || playersJsonString.isEmpty) {
        return [];
      }

      // We'll return raw JSON - the caller will convert to TrainingPlayer
      final List<dynamic> playersJson = jsonDecode(playersJsonString);
      return playersJson;
    } catch (e) {
      return [];
    }
  }

  /// Get active/current training player ID
  static Future<String?> getActiveTrainingPlayerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeTrainingPlayerKey);
    } catch (e) {
      return null;
    }
  }

  /// Set active/current training player ID
  static Future<void> setActiveTrainingPlayerId(String playerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeTrainingPlayerKey, playerId);
    } catch (e) {
      // Error setting active training player ID silently
    }
  }

  /// Delete a training player and all their associated training entries
  static Future<void> deleteTrainingPlayer(String playerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove from players list
      final playersJson = await loadTrainingPlayers();
      final updatedPlayers = playersJson
          .where((p) => (p as Map<String, dynamic>)['id'] != playerId)
          .toList();
      await prefs.setString(_trainingPlayersKey, jsonEncode(updatedPlayers));

      // Remove all training entries for this player
      final strengthData = await loadTrainingEntries('strength_condition');
      final technicalData = await loadTrainingEntries('technical_performance');

      final strengthEntries = (strengthData['entries'] as List)
          .cast<TrainingEntry>()
          .where((e) => e.playerId != playerId)
          .toList();
      final technicalEntries = (technicalData['entries'] as List)
          .cast<TrainingEntry>()
          .where((e) => e.playerId != playerId)
          .toList();

      await saveTrainingEntries(
        strengthEntries,
        strengthData['nextId'] as int,
        'strength_condition',
      );
      await saveTrainingEntries(
        technicalEntries,
        technicalData['nextId'] as int,
        'technical_performance',
      );

      // Clear active player if deleted
      final activeId = await getActiveTrainingPlayerId();
      if (activeId == playerId) {
        await prefs.remove(_activeTrainingPlayerKey);
      }
    } catch (e) {
      // Error clearing active training player silently
    }
  }

  /// Get all training entries for a specific player
  static Future<List<dynamic>> getPlayerTrainingHistory(String playerId) async {
    try {
      final strengthData = await loadTrainingEntries('strength_condition');
      final technicalData = await loadTrainingEntries('technical_performance');

      final strengthEntries = (strengthData['entries'] as List)
          .where((e) => (e as dynamic).playerId == playerId)
          .toList();
      final technicalEntries = (technicalData['entries'] as List)
          .where((e) => (e as dynamic).playerId == playerId)
          .toList();

      return [...strengthEntries, ...technicalEntries];
    } catch (e) {
      return [];
    }
  }

  // ==================== SPEED TRAINING SESSION MANAGEMENT ====================

  /// Save speed training session with attempts and statistics
  static Future<void> saveSpeedTrainingSession({
    required String playerName,
    required String playerId,
    required double targetTime,
    required String targetTimeUnit,
    required double distance,
    required String distanceUnit,
    required List<Map<String, dynamic>> attempts,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = DateTime.now().microsecondsSinceEpoch.toString();
      
      // Calculate statistics from attempts
      final times = attempts
          .map((a) => a['timeInMilliseconds'] as int)
          .toList();
      
      final bestTime = times.isEmpty ? 0 : times.reduce((a, b) => a < b ? a : b);
      final avgTime = times.isEmpty ? 0.0 : times.reduce((a, b) => a + b) / times.length;
      
      final metTargetCount = attempts
          .where((a) => a['metTarget'] as bool)
          .length;
      final successRate = attempts.isEmpty ? 0.0 : (metTargetCount / attempts.length);
      
      // Create session data
      final sessionData = {
        'sessionId': sessionId,
        'playerName': playerName,
        'playerId': playerId,
        'date': DateTime.now().toIso8601String(),
        'type': 'speed_training',
        'targetTime': targetTime,
        'targetTimeUnit': targetTimeUnit,
        'distance': distance,
        'distanceUnit': distanceUnit,
        'attempts': attempts,
        'totalAttempts': attempts.length,
        'bestTime': bestTime,
        'averageTime': avgTime,
        'successRate': successRate,
      };
      
      // Get existing sessions
      final savedSessionsJson = prefs.getString('saved_speed_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);
      
      // Add new session
      savedSessions.add(sessionData);
      
      // Save back to storage
      await prefs.setString('saved_speed_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error saving speed training session silently
      rethrow; // Re-throw to allow UI to handle errors
    }
  }

  /// Load saved speed training sessions, optionally filtered by playerId
  static Future<List<Map<String, dynamic>>> loadSpeedTrainingSessions({
    String? playerId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_speed_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);
      
      List<Map<String, dynamic>> sessions = savedSessions.cast<Map<String, dynamic>>();
      
      // Filter by playerId if provided
      if (playerId != null) {
        sessions = sessions
            .where((session) => session['playerId'] == playerId)
            .toList();
      }
      
      // Sort by date, newest first
      sessions.sort((a, b) {
        final dateA = DateTime.parse(a['date'] as String);
        final dateB = DateTime.parse(b['date'] as String);
        return dateB.compareTo(dateA);
      });
      
      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// Delete a speed training session by sessionId
  static Future<void> deleteSpeedTrainingSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionsJson = prefs.getString('saved_speed_training_sessions') ?? '[]';
      final List<dynamic> savedSessions = jsonDecode(savedSessionsJson);
      
      // Remove session with matching sessionId
      savedSessions.removeWhere((session) {
        return (session as Map<String, dynamic>)['sessionId'] == sessionId;
      });
      
      // Save back
      await prefs.setString('saved_speed_training_sessions', jsonEncode(savedSessions));
    } catch (e) {
      // Error deleting speed training session silently
    }
  }

  /// Get a specific speed training session by sessionId
  static Future<Map<String, dynamic>?> getSpeedTrainingSession(String sessionId) async {
    try {
      final sessions = await loadSpeedTrainingSessions();
      
      for (final session in sessions) {
        if (session['sessionId'] == sessionId) {
          return session;
        }
      }
      
      return null; // Not found
    } catch (e) {
      return null;
    }
  }
}
