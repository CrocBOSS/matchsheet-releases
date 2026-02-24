import 'dart:io';
import '../models/match_entry.dart';

class DocumentService {
  // Parse TXT file and extract player list
  // Expected format: each line contains "NUMBER,NAME"
  // Example:
  // 1,John Keeper
  // 7,James Forward
  // 5,Mike Defender
  Future<List<Player>> parseMatchSheetDocument(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Text file not found');
      }

      final content = await file.readAsString();
      final players = _extractPlayersFromText(content);
      return players;
    } catch (e) {
      throw Exception('Error parsing document: $e');
    }
  }

  // Extract players from text content
  List<Player> _extractPlayersFromText(String content) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final players = <Player>[];
    
    int playerId = 1;
    for (final line in lines) {
      try {
        final parts = line.split(',');
        if (parts.length >= 2) {
          final number = int.tryParse(parts[0].trim());
          final name = parts[1].trim();
          
          if (number != null && name.isNotEmpty) {
            players.add(Player(
              id: playerId++,
              number: number,
              name: name,
            ));
          }
        }
      } catch (e) {
        // Skip malformed lines
        continue;
      }
    }
    
    return players;
  }

  // Save players data to TXT file
  Future<void> savePlayersToTxt(String filePath, List<Player> players) async {
    try {
      final file = File(filePath);
      final content = players.map((p) => '${p.number},${p.name}').join('\n');
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Error saving players data: $e');
    }
  }

  // Load players data from TXT file
  Future<List<Player>> loadPlayersFromTxt(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return [];
      }
      final content = await file.readAsString();
      return _extractPlayersFromText(content);
    } catch (e) {
      throw Exception('Error loading players data: $e');
    }
  }
}
