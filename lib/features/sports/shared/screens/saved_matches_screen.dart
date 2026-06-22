import 'package:flutter/material.dart';

import '../../../../services/storage_service.dart';
import '../../../../core/services/export/export_service.dart';
import '../../../../core/services/export/txt_export_strategy.dart';
import '../../../../core/services/export/excel_export_strategy.dart';
import '../../../../core/services/export/match_export_helper.dart';
import 'match_sheet_screen.dart';



class SavedMatchesScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoadMatch;
  final String sport;

  const SavedMatchesScreen({
    Key? key,
    required this.onLoadMatch,
    required this.sport,
  }) : super(key: key);

  @override
  State<SavedMatchesScreen> createState() => _SavedMatchesScreenState();
}

class _SavedMatchesScreenState extends State<SavedMatchesScreen> with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _savedMatches;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMatches();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes/screen comes back to focus
      if (mounted) {
        setState(() {
          _loadMatches();
        });
      }
    }
  }

  void _loadMatches() {
    _savedMatches = StorageService.loadSavedSessions(sport: widget.sport);
  }

  void _deleteMatch(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Match'),
          content: const Text('Are you sure you want to delete this saved match?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await StorageService.deleteSession(index);
                  Navigator.pop(context);
                  setState(() {
                    _loadMatches();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Match deleted'),
                      duration: Duration(milliseconds: 600),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting: $e'),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrailingActions(bool isUnsavedMatch, Map<String, dynamic> match, int index) {
    if (isUnsavedMatch) {
      // For unsaved match, just show the save button
      return IconButton(
        icon: const Icon(Icons.save, color: Colors.green),
        onPressed: () => _renameUnsavedMatch(match, index),
        tooltip: 'Save with Name',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      );
    } else {
      // For named matches, show a menu with options
      return PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        onSelected: (String value) {
          if (value == 'view') {
            _viewMatch(match);
          } else if (value == 'export') {
            _exportMatch(match);
          } else if (value == 'delete') {
            _deleteMatch(index);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'view',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('View'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'export',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.download, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text('Export'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.more_vert, color: Colors.grey[600]),
        ),
      );
    }
  }

  void _renameUnsavedMatch(Map<String, dynamic> match, int index) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Unsaved Match'),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Give this unsaved match a name to save it permanently:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Match Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await StorageService.renameUnsavedMatch(newName);
                    
                    // Get the updated match data with the new name
                    final updatedMatch = {
                      ...match,
                      'name': newName,
                    };
                    
                    Navigator.pop(context); // Close rename dialog
                    
                    // Load the match on HomeScreen
                    widget.onLoadMatch(updatedMatch);
                    Navigator.pop(context); // Go back to HomeScreen
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Match saved as "$newName". Continue editing!'),
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error renaming: $e'),
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save', style: TextStyle(fontSize: 12, color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _viewMatch(Map<String, dynamic> match) {
    final (playersData, statTypesData, _) = StorageService.parseSessionData(match);
    final teamName = match['teamName'] as String? ?? 'Team A';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSheetScreen(
          players: playersData,
          statTypes: statTypesData,
          teamName: teamName,
        ),
      ),
    );
  }

  Future<void> _exportMatch(Map<String, dynamic> match) async {
    // Show format selection dialog
    final exportFormat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format', style: TextStyle(fontSize: 16)),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select export format:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Text File (.txt)', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context, 'txt'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel File (.xlsx)', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (exportFormat == null) return;

    try {
      // Parse session data using helper function
      final (playersData, statTypesData, _) = StorageService.parseSessionData(match);

      // Get team name from match data if available
      final teamName = match['teamName'] as String? ?? 'Team A';

      final exportService = ExportService();
      final fileName = 'match_${match['name']}_${DateTime.now().millisecondsSinceEpoch}';

      if (exportFormat == 'excel') {
        // Generate Excel data
        final excelData = MatchExportHelper.generateMatchSheetExcel(
          playersData,
          statTypesData,
          teamName: teamName,
        );

        await exportService.exportAndShare(
          data: excelData,
          strategy: ExcelExportStrategy(),
          fileName: fileName,
          subject: 'Match Sheet Export',
        );
      } else {
        // Generate text data
        final textData = MatchExportHelper.generateMatchSheetText(
          playersData,
          statTypesData,
          teamName: teamName,
        );

        await exportService.exportAndShare(
          data: textData,
          strategy: TxtExportStrategy(),
          fileName: fileName,
          subject: 'Match Sheet Export',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match exported successfully!'),
            duration: Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            duration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Matches'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMatches();
          // Wait a bit for the future to complete
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _savedMatches,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading matches: ${snapshot.error}'),
            );
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(
              child: Text('No saved matches yet'),
            );
          }

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final name = match['name'] as String;
              final timestamp = match['timestamp'] as String;
              final players = match['players'] as List<dynamic>;
              final isUnsavedMatch = name == StorageService.UNSAVED_MATCH_NAME;
              
              // Parse timestamp
              DateTime dateTime;
              try {
                dateTime = DateTime.parse(timestamp);
              } catch (e) {
                dateTime = DateTime.now();
              }
              
              final formattedDate =
                  '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

              final displayName = isUnsavedMatch ? '📝 Unsaved Match' : name;
              final backgroundColor = isUnsavedMatch ? Colors.amber[50] : null;
              final borderColor = isUnsavedMatch ? Colors.amber[300] : Colors.transparent;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    isUnsavedMatch ? Icons.edit_note : Icons.sports_soccer,
                    color: isUnsavedMatch ? Colors.amber[700] : Colors.blue,
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: isUnsavedMatch ? FontWeight.bold : FontWeight.normal,
                      color: isUnsavedMatch ? Colors.amber[900] : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    '$formattedDate • ${players.length} players${isUnsavedMatch ? ' • Click to continue or save with a name' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnsavedMatch ? Colors.amber[700] : Colors.grey[600],
                    ),
                  ),
                  trailing: _buildTrailingActions(isUnsavedMatch, match, index),
                  onTap: () {
                    widget.onLoadMatch(match);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUnsavedMatch
                              ? 'Unsaved match restored. Continue working or save with a name!'
                              : 'Loaded: $name',
                        ),
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}
