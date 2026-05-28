import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/match_entry.dart';
import '../../models/stat_type.dart';
import '../../services/storage_service.dart';
import '../../utils/dialog_helpers.dart';
import 'settings_screen.dart';
import '../shared/saved_matches_screen.dart';

class SoccerScreen extends StatefulWidget {
  const SoccerScreen({Key? key}) : super(key: key);

  @override
  State<SoccerScreen> createState() => _SoccerScreenState();
}

class _SoccerScreenState extends State<SoccerScreen> {
  List<Player> players = [];
  List<StatType> statTypes = [];
  List<StatType> positions = [];
  int nextPlayerId = 1;
  int currentHalf = 1; // 1 for first half, 2 for second half
  String? currentSessionName; // Track the currently loaded/active session
  String teamName = 'Team A'; // Team name for the current session
  bool hasUnsavedChanges = false; // Track if there are unsaved changes
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    // Initialize with defaults immediately so UI renders
    statTypes = StorageService.getDefaultStatTypes();
    positions = StorageService.getDefaultPositions();
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final playersData = await StorageService.loadPlayers();
    final loadedStatTypes = await StorageService.loadStatTypes();
    final loadedPositions = await StorageService.loadPositions();
    
    setState(() {
      players = List<Player>.from(playersData['players'] as List);
      nextPlayerId = playersData['nextId'] as int;
      // If no stat types loaded, use defaults (already initialized above)
      statTypes = loadedStatTypes.isEmpty ? statTypes : loadedStatTypes;
      positions = loadedPositions.isEmpty ? positions : loadedPositions;
      hasUnsavedChanges = false;
    });
    
    // Check for unsaved match session
    _checkForUnsavedMatch();
  }

  Future<void> _checkForUnsavedMatch() async {
    final hasUnsaved = await StorageService.hasUnsavedMatch();
    
    if (hasUnsaved && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unsaved Match Found', style: TextStyle(fontSize: 16)),
            content: const Text(
              'You have an unsaved match from your last session. Would you like to continue working on it?',
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await StorageService.deleteUnsavedMatch();
                  Navigator.pop(context);
                  await _createDefaultUnsavedMatch();
                },
                child: const Text('Discard', style: TextStyle(fontSize: 12, color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  await _restoreUnsavedMatch();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Continue', style: TextStyle(fontSize: 12, color: Colors.blue)),
              ),
            ],
          );
        },
      );
    } else if (!hasUnsaved && mounted) {
      // No unsaved match exists, create a default one
      await _createDefaultUnsavedMatch();
    }
  }

  Future<void> _createDefaultUnsavedMatch() async {
    // Create a default unsaved match
    try {
      await StorageService.saveGameSession(
        StorageService.UNSAVED_MATCH_NAME,
        [],
        statTypes,
        1,
        teamName: 'Team A',
        sport: 'soccer',
      );
      
      setState(() {
        currentSessionName = StorageService.UNSAVED_MATCH_NAME;
        players = [];
        nextPlayerId = 1;
        teamName = 'Team A';
        hasUnsavedChanges = false;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _restoreUnsavedMatch() async {
    final unsavedData = await StorageService.getUnsavedMatch();
    if (unsavedData != null) {
      final (playersData, statTypesData, nextId) = StorageService.parseSessionData(unsavedData);
      
      setState(() {
        players = playersData;
        statTypes = statTypesData;
        nextPlayerId = nextId;
        currentSessionName = StorageService.UNSAVED_MATCH_NAME;
        teamName = unsavedData['teamName'] as String? ?? 'Team A';
        hasUnsavedChanges = false;
        currentHalf = 1;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unsaved match restored. Keep working or save with a new name!'),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
    }
  }

  Future<void> _autoSaveGame() async {
    if (!mounted || currentSessionName == null) return;
    try {
      await StorageService.saveGameSession(
        currentSessionName!,
        players,
        statTypes,
        nextPlayerId,
        teamName: teamName,
        sport: 'soccer',
      );
      if (mounted) {
        setState(() {
          hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Silently fail for auto-save
    }
  }

  void _addPlayer() {
    showDialog(
      context: context,
      builder: (context) {
        final numberController = TextEditingController();
        final nameController = TextEditingController();
        String? selectedPosition;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Player', style: TextStyle(fontSize: 16)),
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: 'Jersey Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Player Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: positions
                          .map((pos) => DropdownMenuItem(
                                value: pos.key,
                                child: Text(pos.label, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedPosition = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () {
                    if (numberController.text.isNotEmpty && nameController.text.isNotEmpty) {
                      setState(() {
                        final newPlayer = Player(
                          id: nextPlayerId++,
                          number: int.parse(numberController.text),
                          name: nameController.text,
                          position: selectedPosition ?? '',
                          teamName: players.isEmpty ? teamName : '',
                        );
                        players.add(newPlayer);
                        // If this is the first player, update the team name from the player's teamName
                        if (players.length == 1) {
                          teamName = newPlayer.teamName;
                        }
                        hasUnsavedChanges = true;
                        _autoSaveGame();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add', style: TextStyle(fontSize: 12)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _incrementStat(Player player, String statName) {
    setState(() {
      final index = players.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        final updatedPlayer = _getUpdatedPlayer(player, statName, 1);
        players[index] = updatedPlayer;
      }
      hasUnsavedChanges = true;
      _autoSaveGame();
    });
  }

  void _decrementStat(Player player, String statName) {
    setState(() {
      final index = players.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        final updatedPlayer = _getUpdatedPlayer(player, statName, -1);
        players[index] = updatedPlayer;
      }
      hasUnsavedChanges = true;
      _autoSaveGame();
    });
  }

  void _showPlayerNamePopup(Player player) {
    final numberController = TextEditingController(text: player.number.toString());
    final nameController = TextEditingController(text: player.name);
    String? selectedPosition = player.position.isNotEmpty ? player.position : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Player', style: TextStyle(fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jersey Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Player Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: positions
                          .map((pos) => DropdownMenuItem(
                                value: pos.key,
                                child: Text(pos.label, style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedPosition = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () {
                    final newNumber = int.tryParse(numberController.text);
                    final newName = nameController.text.trim();

                    if (newNumber != null && newName.isNotEmpty) {
                      setState(() {
                        final index = players.indexWhere((p) => p.id == player.id);
                        if (index >= 0) {
                          players[index] = player.copyWith(
                            number: newNumber,
                            name: newName,
                            position: selectedPosition ?? '',
                          );
                          _autoSaveGame();
                        }
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Player updated!'),
                          duration: Duration(milliseconds: 600),
                        ),
                      );
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 12, color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTeamNameDialog() {
    final teamNameController = TextEditingController(text: teamName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Team Name', style: TextStyle(fontSize: 16)),
          content: TextField(
            controller: teamNameController,
            decoration: const InputDecoration(
              labelText: 'Team Name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                final newTeamName = teamNameController.text.trim();
                if (newTeamName.isNotEmpty) {
                  setState(() {
                    teamName = newTeamName;
                    // Update the first player's team name to match
                    if (players.isNotEmpty) {
                      players[0] = players[0].copyWith(teamName: newTeamName);
                      _autoSaveGame();
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Team name updated to: $newTeamName'),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(fontSize: 12, color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Player _getUpdatedPlayer(Player player, String statName, int increment) {
    if (currentHalf == 1) {
      // First half - use customStats map (same logic as second half)
      final updatedCustomStats = Map<String, int>.from(player.customStats);
      updatedCustomStats[statName] = (updatedCustomStats[statName] ?? 0) + increment;
      return player.copyWith(customStats: updatedCustomStats);
    } else {
      // Second half - use secondHalfStats map
      final updatedSecondHalf = Map<String, int>.from(player.secondHalfStats);
      updatedSecondHalf[statName] = (updatedSecondHalf[statName] ?? 0) + increment;
      return player.copyWith(secondHalfStats: updatedSecondHalf);
    }
  }

  int _getStatValue(Player player, String statKey) {
    if (currentHalf == 1) {
      // First half stats - all from customStats
      return player.customStats[statKey] ?? 0;
    } else {
      // Second half stats - all from secondHalfStats map
      return player.secondHalfStats[statKey] ?? 0;
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          statTypes: statTypes,
          positions: positions,
          players: players,
          onStatTypesSaved: (newStatTypes) {
            setState(() {
              statTypes = newStatTypes;
            });
          },
          onPositionsSaved: (newPositions) {
            setState(() {
              positions = newPositions;
            });
          },
        ),
      ),
    );
  }

  void _resetForNewGame() {
    // If we have data that's not the unsaved match, ask to save
    if (players.isNotEmpty && currentSessionName != StorageService.UNSAVED_MATCH_NAME) {
      _showSaveGameDialog(
        title: 'Save Current Game',
        contentMessage: 'Save this match before starting a new game?',
        onSaved: () {
          _proceedWithNewUnsavedMatch();
        },
        isNewGame: true,
      );
    } else {
      // If it's already an unsaved match or empty, just create a new one
      _proceedWithNewUnsavedMatch();
    }
  }

  Future<void> _proceedWithNewUnsavedMatch() async {
    // Clear everything
    await StorageService.clearAll();
    
    setState(() {
      players = [];
      nextPlayerId = 1;
      statTypes = StorageService.getDefaultStatTypes();
      currentHalf = 1;
      currentSessionName = StorageService.UNSAVED_MATCH_NAME;
      teamName = 'Team A'; // Reset team name
      hasUnsavedChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New unsaved match created. Start adding players!'),
        duration: Duration(milliseconds: 600),
      ),
    );
  }

  void _showSaveGameDialog({
    required String title,
    required String contentMessage,
    required Function() onSaved,
    bool isNewGame = false,
  }) {
    final saveNameController = TextEditingController();
    final isUnsavedMatch = currentSessionName == StorageService.UNSAVED_MATCH_NAME;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title, style: const TextStyle(fontSize: 16)),
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contentMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: saveNameController,
                    onChanged: (value) {
                      setState(() {}); // Rebuild to update button text
                    },
                    decoration: InputDecoration(
                      labelText: 'Game Name',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      hintText: isUnsavedMatch
                        ? 'Enter a name to save this match'
                        : 'Leave blank to update or enter new name',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () async {
                    String gameName = saveNameController.text.trim();
                    bool shouldSave = false;

                    // Determine if we should save
                    if (gameName.isNotEmpty) {
                      // New name provided
                      shouldSave = true;
                    } else if (!isUnsavedMatch && currentSessionName != null && players.isNotEmpty) {
                      // No name provided but a named session is loaded, update existing
                      gameName = currentSessionName!;
                      shouldSave = true;
                    }

                    if (shouldSave) {
                      try {
                        // First delete the old session if updating (and it's not unsaved match)
                        if (!isUnsavedMatch && currentSessionName != null && gameName == currentSessionName) {
                          final sessions = await StorageService.loadSavedSessions();
                          final index = sessions.indexWhere((s) => s['name'] == currentSessionName);
                          if (index >= 0) {
                            await StorageService.deleteSession(index);
                          }
                        }

                        // If updating unsaved match with a new name, rename it
                        if (isUnsavedMatch && gameName.isNotEmpty && gameName != StorageService.UNSAVED_MATCH_NAME) {
                          await StorageService.renameUnsavedMatch(gameName);
                          currentSessionName = gameName;
                        } else {
                          // Save as new session
                          await StorageService.saveGameSession(
                            gameName,
                            players,
                            statTypes,
                            nextPlayerId,
                            teamName: teamName,
                            sport: 'soccer',
                          );
                        }
                        
                        if (mounted) {
                          setState(() {
                            currentSessionName = gameName;
                            hasUnsavedChanges = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Game "$gameName" saved!'),
                              duration: const Duration(milliseconds: 600),
                            ),
                          );
                          Navigator.pop(context);
                          onSaved(); // Only call after successful save
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving: $e'),
                              duration: const Duration(milliseconds: 600),
                            ),
                          );
                        }
                      }
                    } else {
                      // No save happened, just close dialog
                      if (mounted) {
                        Navigator.pop(context);
                        if (isNewGame) {
                          onSaved(); // Proceed with new game even without saving
                        }
                      }
                    }
                  },
                  child: Text(
                    saveNameController.text.isNotEmpty
                        ? (isUnsavedMatch ? 'Save With Name' : 'Save & Continue')
                        : ((!isUnsavedMatch && currentSessionName != null && players.isNotEmpty)
                            ? 'Save & Continue'
                            : 'Continue without Saving'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _openSavedMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedMatchesScreen(
          sport: 'soccer',
          onLoadMatch: (sessionData) {
            _loadGameSession(sessionData);
          },
        ),
      ),
    );
  }

  Future<void> _loadGameSession(Map<String, dynamic> sessionData) async {
    try {
      // Parse session data using helper function
      final (playersData, statTypesData, nextId) = StorageService.parseSessionData(sessionData);
      
      setState(() {
        players = playersData;
        statTypes = statTypesData;
        nextPlayerId = nextId;
        currentHalf = 1;
        currentSessionName = sessionData['name'] as String;
        // Extract team name from session data or use first player's team name or default
        if (players.isNotEmpty) {
          teamName = players.first.teamName;
        } else {
          teamName = 'Team A';
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded: ${sessionData['name']}'),
          duration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading match: $e'),
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  Future<void> _importPlayersFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final (parsedPlayers, importedTeamName) = StorageService.parsePlayersFromText(content);

      if (parsedPlayers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid players found in file. Format: jersey,name'),
            duration: Duration(milliseconds: 900),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Import Players'),
            content: Text(
              'Found ${parsedPlayers.length} players. Import them?\n\n'
              'Players will be added to the current match.\n'
              'Team: $importedTeamName',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Update team name if a new one was found
                    if (importedTeamName != 'Team A' || teamName == 'Team A') {
                      teamName = importedTeamName;
                    }
                    
                    for (final playerData in parsedPlayers) {
                      final newPlayer = Player(
                        id: nextPlayerId++,
                        number: playerData['number'] as int,
                        name: playerData['name'] as String,
                      );
                      players.add(newPlayer);
                    }
                    _autoSaveGame();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${parsedPlayers.length} players imported!'),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                },
                child: const Text('Import'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reading file: $e'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _updateComment(Player player, String comment) {
    setState(() {
      final index = players.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        players[index] = player.copyWith(comments: comment);
      }
      hasUnsavedChanges = true;
      _autoSaveGame();
    });
  }

  void _showPlayerDeleteMenu(Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Player', style: TextStyle(color: Colors.red, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeletePlayerConfirmation(player);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel', style: TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeletePlayerConfirmation(Player player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Player', style: TextStyle(fontSize: 16)),
          content: Text(
            'Are you sure you want to delete ${player.number} - ${player.name}?',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  players.removeWhere((p) => p.id == player.id);
                  _autoSaveGame();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${player.number} - ${player.name} deleted'),
                    duration: const Duration(milliseconds: 600),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToTxt() async {
    final content = StorageService.generateMatchSheetText(players, statTypes, teamName: teamName);
    
    try {
      // For mobile: save to temp directory and share
      final fileName = 'match_sheet_${DateTime.now().millisecondsSinceEpoch}.txt';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);
      
      // Share the file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Match Sheet Export',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match sheet exported successfully!'),
          duration: Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _showSaveExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Check if players list is empty
        if (players.isEmpty) {
          return AlertDialog(
            title: const Text('No Players', style: TextStyle(fontSize: 16)),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add players to get started!',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You need to add at least one player before you can save or export.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }
        
        // Normal dialog with save/export options
        return AlertDialog(
          title: const Text('Save or Export', style: TextStyle(fontSize: 16)),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          content: const Text(
            'Choose an action:',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSaveGameDialog(
                  title: 'Save Game',
                  contentMessage: 'Save this match?',
                  onSaved: () => setState(() { hasUnsavedChanges = false; }),
                );
              },
              child: const Text('Save', style: TextStyle(fontSize: 12, color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportToTxt();
              },
              child: const Text('Export', style: TextStyle(fontSize: 12, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    // Responsive column widths
    final playerWidth = screenWidth > 1200 ? 110.0 : screenWidth > 600 ? 80.0 : 70.0;
    final statColumnWidth = screenWidth > 1200 ? 80.0 : screenWidth > 600 ? 65.0 : 55.0;
    final commentColumnWidth = screenWidth > 1200 ? 100.0 : screenWidth > 600 ? 70.0 : 55.0;
    
    // Responsive font sizes
    final headerFontSize = screenWidth > 1200 ? 14.0 : screenWidth > 600 ? 12.0 : 10.0;
    final playerNameFontSize = screenWidth > 1200 ? 14.0 : screenWidth > 600 ? 12.0 : 10.0;
    final playerNumberFontSize = screenWidth > 1200 ? 24.0 : screenWidth > 600 ? 20.0 : 16.0;
    final statValueFontSize = screenWidth > 1200 ? 14.0 : screenWidth > 600 ? 12.0 : 10.0;
    
    // Responsive button sizes
    final buttonMinSize = screenWidth > 1200 ? const Size(50, 35) : screenWidth > 600 ? const Size(45, 30) : const Size(40, 25);
    final buttonPadding = screenWidth > 1200 ? 4.0 : screenWidth > 600 ? 3.0 : 2.0;
    
    // AppBar sizing - shrink in landscape mode
    final appBarHeight = isLandscape ? 45.0 : 56.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (hasUnsavedChanges) {
          bool? shouldPop = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Unsaved Changes', style: TextStyle(fontSize: 16)),
                content: const Text(
                  'You have unsaved changes. Go back without saving?',
                  style: TextStyle(fontSize: 13),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Discard', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              );
            },
          );
          if (shouldPop ?? false) {
            if (mounted) Navigator.pop(context);
          }
        } else {
          if (mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: screenWidth > 600
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Soccer Statistics Tracker',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isLandscape ? 12 : 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => currentHalf = 1),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 8 : 12,
                              vertical: isLandscape ? 3 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: currentHalf == 1 ? Colors.white : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(2),
                                bottomLeft: Radius.circular(2),
                              ),
                            ),
                            child: Text(
                              '1st Half',
                              style: TextStyle(
                                color: currentHalf == 1 ? Colors.blue : Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 11 : 12,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => currentHalf = 2),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 8 : 12,
                              vertical: isLandscape ? 3 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: currentHalf == 2 ? Colors.white : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                            child: Text(
                              '2nd Half',
                              style: TextStyle(
                                color: currentHalf == 2 ? Colors.blue : Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 11 : 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Tooltip(
                message: 'Soccer Statistics Tracker',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => currentHalf = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentHalf == 1 ? Colors.white : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              bottomLeft: Radius.circular(2),
                            ),
                          ),
                          child: Text(
                            '1st',
                            style: TextStyle(
                              color: currentHalf == 1 ? Colors.blue : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => currentHalf = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentHalf == 2 ? Colors.white : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                          child: Text(
                            '2nd',
                            style: TextStyle(
                              color: currentHalf == 2 ? Colors.blue : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(isLandscape ? 2 : buttonPadding),
                  child: screenWidth > 500
                      ? ElevatedButton.icon(
                          onPressed: _resetForNewGame,
                          icon: Icon(Icons.restart_alt, size: isLandscape ? 14 : 16),
                          label: Text('New Game', style: TextStyle(fontSize: isLandscape ? 9 : 11)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 6 : 8,
                              vertical: isLandscape ? 2 : 4,
                            ),
                            minimumSize: Size(isLandscape ? 70 : 80, isLandscape ? 28 : 32),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : IconButton(
                          onPressed: _resetForNewGame,
                          icon: const Icon(Icons.restart_alt),
                          tooltip: 'New Game',
                          color: Colors.red,
                          iconSize: isLandscape ? 18 : 24,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(isLandscape ? 2 : buttonPadding),
                  child: screenWidth > 500
                      ? ElevatedButton.icon(
                          onPressed: _openSettings,
                          icon: Icon(Icons.settings, size: isLandscape ? 14 : 16),
                          label: Text('Settings', style: TextStyle(fontSize: isLandscape ? 9 : 11)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 6 : 8,
                              vertical: isLandscape ? 2 : 4,
                            ),
                            minimumSize: Size(isLandscape ? 70 : 80, isLandscape ? 28 : 32),
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                          ),
                        )
                      : IconButton(
                          onPressed: _openSettings,
                          icon: const Icon(Icons.settings),
                          tooltip: 'Settings',
                          color: Colors.grey[700 ],
                          iconSize: isLandscape ? 18 : 24,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(isLandscape ? 2 : buttonPadding),
                  child: screenWidth > 500
                      ? Stack(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showSaveExportDialog,
                              icon: Icon(Icons.download, size: isLandscape ? 14 : 16),
                              label: Text('Save/Export', style: TextStyle(fontSize: isLandscape ? 9 : 11)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 6 : 8,
                                  vertical: isLandscape ? 2 : 4,
                                ),
                                minimumSize: Size(isLandscape ? 70 : 80, isLandscape ? 28 : 32),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (hasUnsavedChanges)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Stack(
                          children: [
                            IconButton(
                              onPressed: _showSaveExportDialog,
                              icon: const Icon(Icons.download),
                              tooltip: 'Save/Export',
                              color: Colors.green,
                              iconSize: isLandscape ? 18 : 24,
                            ),
                            if (hasUnsavedChanges)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(isLandscape ? 2 : buttonPadding),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'saved_matches') {
                        _openSavedMatches();
                      } else if (value == 'import_players') {
                        _importPlayersFromFile();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'saved_matches',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Saved Matches'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'import_players',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Import Players'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.menu),
                    color: Colors.white,
                    iconSize: isLandscape ? 18 : 24,
                    tooltip: 'Menu',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Team Name Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.67, 1.0],
                colors: [Colors.blue[900]!, Colors.white, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showEditTeamNameDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: screenWidth > 600 ? 16 : 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            teamName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth > 600 ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    currentHalf == 1 ? 'First Half' : 'Second Half',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 600 ? 12 : 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header Row
          Container(
            color: Colors.grey[800],
            child: Row(
              children: [
                SizedBox(
                  width: playerWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Player',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Stat headers
                        ...(_buildStatHeaders(context, statColumnWidth, headerFontSize)),
                        // Comments header
                        SizedBox(
                          width: commentColumnWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Comments',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Player Rows - Wrapped with horizontal scroll
          Expanded(
            child: players.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No players added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add players',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
              itemCount: players.length,
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                final player = players[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Player Name Column
                      SizedBox(
                        width: playerWidth,
                        child: GestureDetector(
                          onTap: () {
                            _showPlayerNamePopup(player);
                          },
                          onLongPress: () {
                            _showPlayerDeleteMenu(player);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '#${player.number}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: playerNumberFontSize,
                                  ),
                                ),
                                Text(
                                  player.position.isNotEmpty ? player.position : '-',
                                  style: TextStyle(
                                    fontSize: playerNameFontSize * 0.8,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  player.name,
                                  style: TextStyle(fontSize: playerNameFontSize),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Stat Buttons + Comments - All scrollable together
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Stat Buttons
                              ...(_buildStatButtons(player, statColumnWidth, buttonMinSize, buttonPadding, statValueFontSize)),
                              // Comments Button
                              SizedBox(
                                width: commentColumnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () => _showCommentDialog(player),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(2),
                                      minimumSize: const Size(10, 10),
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Icon(Icons.comment, size: 16),
                                  ),
                                ),
                              ),
                              // Rating Button with Star
                              SizedBox(
                                width: commentColumnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Rating Label
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          'Rating',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _showRatingDialog(player),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(4),
                                          minimumSize: const Size(30, 30),
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Icon(Icons.star, size: 16),
                                      ),
                                      // Rating Value
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          player.rating > 0 ? '${player.rating}' : '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        backgroundColor: Colors.green,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      ),
    );
  }

  void _showRatingDialog(Player player) {
    DialogHelpers.showRatingDialog(
      context: context,
      title: 'Rate ${player.number} - ${player.name}',
      currentRating: player.rating,
      onRate: (rating) => _updateRating(player, rating),
    );
  }

  void _updateRating(Player player, int rating) {
    setState(() {
      final index = players.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        players[index] = player.copyWith(rating: rating);
      }
      hasUnsavedChanges = true;
      _autoSaveGame();
    });
  }

  void _showCommentDialog(Player player) {
    DialogHelpers.showTextInputDialog(
      context: context,
      title: '${player.number} - ${player.name}',
      initialText: player.comments,
      labelText: 'Comments',
      maxLines: 3,
      onSave: (text) => _updateComment(player, text),
    );
  }

  List<Widget> _buildStatHeaders(BuildContext context, double columnWidth, double headerFontSize) {
    return statTypes
        .map((stat) => SizedBox(
              width: columnWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: headerFontSize,
                          ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildStatButtons(Player player, double columnWidth, Size buttonMinSize, double buttonPadding, double statValueFontSize) {
    return statTypes
        .map((stat) => SizedBox(
              width: columnWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stat Label
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        stat.label,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () => _decrementStat(player, stat.key),
                      child: ElevatedButton(
                        onPressed: () => _incrementStat(player, stat.key),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(buttonPadding),
                          minimumSize: buttonMinSize,
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          '+',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${_getStatValue(player, stat.key)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: statValueFontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}
