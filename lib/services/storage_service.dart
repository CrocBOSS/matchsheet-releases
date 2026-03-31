import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_entry.dart';
import '../models/stat_type.dart';

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

  /// Generate match sheet as text with header, JSON players, and summary for both halves
  static String generateMatchSheetText(List<Player> players, List<StatType> statTypes, {String teamName = 'Team A'}) {
    final buffer = StringBuffer();
    
    // Collect all stat keys (default + custom)
    final Set<String> allStatKeys = {};
    for (final stat in statTypes) {
      allStatKeys.add(stat.key);
    }
    // Add custom stat keys from players
    for (final player in players) {
      allStatKeys.addAll(player.customStats.keys);
      allStatKeys.addAll(player.secondHalfStats.keys);
    }
    
    // Header
    buffer.writeln('=== MATCH SHEET ===');
    buffer.writeln('Team Name: $teamName');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('');
    
    // FULL MATCH SUMMARY - combines first and second half data
    buffer.writeln('=== FULL MATCH SUMMARY ===');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final firstHalfTotal = _calculateFirstHalfStatTotal(players, stat.key);
      final secondHalfTotal = _calculateSecondHalfStatTotal(players, stat.key);
      final fullMatchTotal = firstHalfTotal + secondHalfTotal;
      buffer.writeln('Total ${stat.label}: $fullMatchTotal (1st: $firstHalfTotal, 2nd: $secondHalfTotal)');
    }
    // Add custom stats totals
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final firstHalfTotal = _calculateFirstHalfCustomStatTotal(players, customKey);
        final secondHalfTotal = _calculateSecondHalfStatTotal(players, customKey);
        final fullMatchTotal = firstHalfTotal + secondHalfTotal;
        buffer.writeln('Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $fullMatchTotal (1st: $firstHalfTotal, 2nd: $secondHalfTotal)');
      }
    }
    buffer.writeln('');
    
    // FIRST HALF SECTION - Generate first half data summary
    buffer.writeln('=== FIRST HALF ===');
    buffer.writeln('PLAYER STATISTICS');
    
    // Build first half player JSON with consistent structure (all stat types + custom)
    final firstHalfPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };
      
      // Add all default stat types
      for (final stat in statTypes) {
        json[stat.key] = _getFirstHalfStatValue(p, stat.key);
      }
      
      // Add custom stats (with 0 default if not in first half)
      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          json[customKey] = p.customStats[customKey] ?? 0;
        }
      }
      
      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';
      
      return json;
    }).toList();
    
    const encoder = JsonEncoder.withIndent('  ');
    buffer.writeln(encoder.convert(firstHalfPlayers));
    buffer.writeln('');
    
    // FIRST HALF SUMMARY - Generate summary for first half only
    buffer.writeln('FIRST HALF SUMMARY');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final total = _calculateFirstHalfStatTotal(players, stat.key);
      buffer.writeln('Total ${stat.label}: $total');
    }
    // Add custom stats summary
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final total = _calculateFirstHalfCustomStatTotal(players, customKey);
        buffer.writeln('Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $total');
      }
    }
    buffer.writeln('');
    
    // SECOND HALF SECTION - Generate second half data summary
    buffer.writeln('=== SECOND HALF ===');
    buffer.writeln('PLAYER STATISTICS');
    
    // Build second half player JSON with consistent structure (all stat types + custom)
    final secondHalfPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };
      
      // Add all default stat types from secondHalfStats
      for (final stat in statTypes) {
        json[stat.key] = p.secondHalfStats[stat.key] ?? 0;
      }
      
      // Add custom stats from second half
      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          json[customKey] = p.secondHalfStats[customKey] ?? 0;
        }
      }
      
      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';
      
      return json;
    }).toList();
    
    buffer.writeln(encoder.convert(secondHalfPlayers));
    buffer.writeln('');
    
    // SECOND HALF SUMMARY - Generate summary for second half only
    buffer.writeln('SECOND HALF SUMMARY');
    buffer.writeln('Total Players: ${players.length}');
    for (final stat in statTypes) {
      final total = _calculateSecondHalfStatTotal(players, stat.key);
      buffer.writeln('Total ${stat.label}: $total');
    }
    // Add custom stats summary
    for (final customKey in allStatKeys) {
      if (!statTypes.any((s) => s.key == customKey)) {
        final total = _calculateSecondHalfStatTotal(players, customKey);
        buffer.writeln('Total ${customKey.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')}: $total');
      }
    }
    buffer.writeln('');
    
    // FULL MATCH STATISTICS - Combine first and second half into full match stats
    buffer.writeln('=== FULL MATCH STATISTICS ===');
    final fullMatchPlayers = players.map((p) {
      final json = <String, dynamic>{
        'id': p.id,
        'number': p.number,
        'name': p.name,
        'position': p.position,
      };
      
      // Add all stat types with combined totals from both halves
      for (final stat in statTypes) {
        final firstHalfValue = _getFirstHalfStatValue(p, stat.key);
        final secondHalfValue = p.secondHalfStats[stat.key] ?? 0;
        json[stat.key] = firstHalfValue + secondHalfValue;
      }
      
      // Add custom stats (combined from both halves)
      for (final customKey in allStatKeys) {
        if (!statTypes.any((s) => s.key == customKey)) {
          final firstHalfValue = p.customStats[customKey] ?? 0;
          final secondHalfValue = p.secondHalfStats[customKey] ?? 0;
          json[customKey] = firstHalfValue + secondHalfValue;
        }
      }
      
      json['comments'] = p.comments;
      json['rating'] = p.rating > 0 ? '${p.rating}/10' : '-';
      
      return json;
    }).toList();
    
    buffer.writeln(encoder.convert(fullMatchPlayers));
    
    return buffer.toString();
  }
  
  /// Get first half stat value for a player
  static int _getFirstHalfStatValue(Player player, String statKey) {
    switch (statKey) {
      case 'completedPasses':
        return player.completedPasses;
      case 'interceptions':
        return player.interceptions;
      case 'turnovers':
        return player.turnovers;
      case 'tackles':
        return player.tackles;
      case 'fouls':
        return player.fouls;
      case 'shotsOnTarget':
        return player.shotsOnTarget;
      case 'assists':
        return player.assists;
      case 'goals':
        return player.goals;
      case 'goalkeeperSaves':
        return player.goalkeeperSaves;
      case 'yellowCards':
        return player.yellowCards;
      default:
        return player.customStats[statKey] ?? 0;
    }
  }

  /// Calculate first half total for a specific stat
  static int _calculateFirstHalfStatTotal(List<Player> players, String statKey) {
    int total = 0;
    
    for (final player in players) {
      switch (statKey) {
        case 'completedPasses':
          total += player.completedPasses;
          break;
        case 'interceptions':
          total += player.interceptions;
          break;
        case 'turnovers':
          total += player.turnovers;
          break;
        case 'tackles':
          total += player.tackles;
          break;
        case 'fouls':
          total += player.fouls;
          break;
        case 'shotsOnTarget':
          total += player.shotsOnTarget;
          break;
        case 'assists':
          total += player.assists;
          break;
        case 'goals':
          total += player.goals;
          break;
        case 'goalkeeperSaves':
          total += player.goalkeeperSaves;
          break;
        case 'yellowCards':
          total += player.yellowCards;
          break;
        default:
          total += player.customStats[statKey] ?? 0;
      }
    }
    
    return total;
  }

  /// Calculate first half custom stat total
  static int _calculateFirstHalfCustomStatTotal(List<Player> players, String statKey) {
    int total = 0;
    for (final player in players) {
      total += player.customStats[statKey] ?? 0;
    }
    return total;
  }

  /// Calculate second half total for a specific stat
  static int _calculateSecondHalfStatTotal(List<Player> players, String statKey) {
    int total = 0;
    
    for (final player in players) {
      total += player.secondHalfStats[statKey] ?? 0;
    }
    
    return total;
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
  static Future<void> saveGameSession(String sessionName, List<Player> players, List<StatType> statTypes, int nextId, {String teamName = 'Team A'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create session data
      final sessionData = {
        'name': sessionName,
        'timestamp': DateTime.now().toIso8601String(),
        'teamName': teamName,
        'players': players.map((p) => p.toJson()).toList(),
        'statTypes': statTypes.map((s) => {'key': s.key, 'label': s.label}).toList(),
        'nextId': nextId,
      };
      
      // Get existing saved games list
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      
      // Check if a session with this name already exists
      final existingIndex = savedGames.indexWhere((s) => s['name'] == sessionName);
      
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
      rethrow;
    }
  }

  /// Load all saved game sessions
  static Future<List<Map<String, dynamic>>> loadSavedSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGamesJson = prefs.getString('saved_games') ?? '[]';
      final List<dynamic> savedGames = jsonDecode(savedGamesJson);
      return savedGames.cast<Map<String, dynamic>>();
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }
}
