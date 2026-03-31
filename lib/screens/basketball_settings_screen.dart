import 'package:flutter/material.dart';
import '../models/stat_type.dart';
import '../models/match_entry.dart';
import '../services/storage_service.dart';

class BasketballSettingsScreen extends StatefulWidget {
  final List<StatType> statTypes;
  final List<StatType> positions;
  final List<Player> players;
  final Function(List<StatType>) onStatTypesSaved;
  final Function(List<StatType>) onPositionsSaved;

  const BasketballSettingsScreen({
    Key? key,
    required this.statTypes,
    required this.positions,
    required this.players,
    required this.onStatTypesSaved,
    required this.onPositionsSaved,
  }) : super(key: key);

  @override
  State<BasketballSettingsScreen> createState() => _BasketballSettingsScreenState();
}

class _BasketballSettingsScreenState extends State<BasketballSettingsScreen> with TickerProviderStateMixin {
  late List<StatType> statTypes;
  late List<StatType> positions;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    statTypes = List.from(widget.statTypes);
    positions = List.from(widget.positions);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isStatTypeUsed(String statKey) {
    // Check if any player has a non-zero value for this stat
    for (final player in widget.players) {
      // Check custom stats for basketball
      if ((player.customStats[statKey] ?? 0) != 0) return true;
      if ((player.secondHalfStats[statKey] ?? 0) != 0) return true;
    }
    return false;
  }

  bool _isPositionUsed(String positionKey) {
    // Check if any player has this position assigned
    return widget.players.any((player) => player.position == positionKey);
  }

  void _addStatType() {
    final keyController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Stat Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key (e.g., myCustomStat)',
                    border: OutlineInputBorder(),
                    hintText: 'Internal identifier, no spaces',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Display Label (e.g., My Stat)',
                    border: OutlineInputBorder(),
                    hintText: 'What users see in the UI',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && labelController.text.isNotEmpty) {
                  setState(() {
                    statTypes.add(StatType(
                      key: keyController.text.replaceAll(' ', ''),
                      label: labelController.text,
                    ));
                  });
                  // Auto-save on add
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editStatType(int index) {
    final stat = statTypes[index];
    final labelController = TextEditingController(text: stat.label);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Stat Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: stat.key),
                  decoration: const InputDecoration(
                    labelText: 'Key (read-only)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Display Label',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  setState(() {
                    statTypes[index] = stat.copyWith(label: labelController.text);
                  });
                  // Auto-save on edit
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _removeStatType(int index) {
    final stat = statTypes[index];
    final isUsed = _isStatTypeUsed(stat.key);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Stat Type'),
          content: isUsed
              ? Text(
                  '"${stat.label}" is currently being used in this match.\n\nYou can rename it instead, or it will be deletable after starting a new game.',
                  style: const TextStyle(color: Colors.orange),
                )
              : Text('Remove "${stat.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (isUsed)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editStatType(index);
                },
                child: const Text('Rename Instead', style: TextStyle(color: Colors.blue)),
              ),
            if (!isUsed)
              TextButton(
                onPressed: () {
                  setState(() {
                    statTypes.removeAt(index);
                  });
                  // Auto-save on remove
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                },
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset to Defaults'),
          content: const Text('This will restore the default basketball stat types.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  statTypes = StorageService.getDefaultBasketballStatTypes();
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _addPosition() {
    final keyController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Position'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key (e.g., PG)',
                    border: OutlineInputBorder(),
                    hintText: 'Internal identifier, no spaces',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Display Label (e.g., Point Guard)',
                    border: OutlineInputBorder(),
                    hintText: 'What users see in the UI',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && labelController.text.isNotEmpty) {
                  setState(() {
                    positions.add(StatType(
                      key: keyController.text.replaceAll(' ', ''),
                      label: labelController.text,
                    ));
                  });
                  // Auto-save on add
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editPosition(int index) {
    final position = positions[index];
    final labelController = TextEditingController(text: position.label);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Position'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: position.key),
                  decoration: const InputDecoration(
                    labelText: 'Key (read-only)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Display Label',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  setState(() {
                    positions[index] = position.copyWith(label: labelController.text);
                  });
                  // Auto-save on edit
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _removePosition(int index) {
    final position = positions[index];
    final isUsed = _isPositionUsed(position.key);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Position'),
          content: isUsed
              ? Text(
                  '"${position.label}" is currently assigned to a player.\n\nYou can rename it instead, or it will be deletable after starting a new game.',
                  style: const TextStyle(color: Colors.orange),
                )
              : Text('Remove "${position.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (isUsed)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editPosition(index);
                },
                child: const Text('Rename Instead', style: TextStyle(color: Colors.blue)),
              ),
            if (!isUsed)
              TextButton(
                onPressed: () {
                  setState(() {
                    positions.removeAt(index);
                  });
                  // Auto-save on remove
                  _saveStatTypesAndPositions();
                  Navigator.pop(context);
                },
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  void _resetPositionsToDefaults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset to Defaults'),
          content: const Text('This will restore the default basketball positions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  positions = StorageService.getDefaultBasketballPositions();
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveStatTypesAndPositions() async {
    await StorageService.saveStatTypes(statTypes);
    await StorageService.savePositions(positions);
    widget.onStatTypesSaved(statTypes);
    widget.onPositionsSaved(positions);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final appBarHeight = isLandscape ? 45.0 : 56.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: const Text('Basketball Settings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stat Types'),
            Tab(text: 'Positions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stat Types Tab
          Column(
            children: [
              // Reset Button - only show in portrait mode
              if (!isLandscape)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset to Defaults'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Basketball Stat Types',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              // Stat Types List
              Expanded(
                child: ListView.builder(
                  itemCount: statTypes.length,
                  itemBuilder: (context, index) {
                    final stat = statTypes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(stat.label),
                      subtitle: Text(stat.key),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: () => _editStatType(index),
                          ),
                          PopupMenuItem(
                            child: const Text('Remove', style: TextStyle(color: Colors.red)),
                            onTap: () => _removeStatType(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Positions Tab
          Column(
            children: [
              // Reset Button - only show in portrait mode
              if (!isLandscape)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _resetPositionsToDefaults,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset to Defaults'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Basketball Positions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              // Positions List
              Expanded(
                child: ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (context, index) {
                    final position = positions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(position.label),
                      subtitle: Text(position.key),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: () => _editPosition(index),
                          ),
                          PopupMenuItem(
                            child: const Text('Remove', style: TextStyle(color: Colors.red)),
                            onTap: () => _removePosition(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            if (_tabController.index == 0) {
              _addStatType();
            } else {
              _addPosition();
            }
          },
          icon: const Icon(Icons.add),
          label: Text(_tabController.index == 0 ? 'Add Stat Type' : 'Add Position'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
