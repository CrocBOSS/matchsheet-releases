import 'package:flutter/material.dart';
import '../../../models/stat_type.dart';

class TechnicalSettingsScreen extends StatefulWidget {
  final List<StatType> statTypes;
  final Function(List<StatType>) onStatTypesChanged;

  const TechnicalSettingsScreen({
    Key? key,
    required this.statTypes,
    required this.onStatTypesChanged,
  }) : super(key: key);

  @override
  State<TechnicalSettingsScreen> createState() => _TechnicalSettingsScreenState();
}

class _TechnicalSettingsScreenState extends State<TechnicalSettingsScreen> {
  late List<StatType> statTypes;

  @override
  void initState() {
    super.initState();
    statTypes = List.from(widget.statTypes);
  }

  void _editStatType(int index, StatType statType) {
    setState(() {
      statTypes[index] = statType;
    });
    widget.onStatTypesChanged(statTypes);
  }

  void _addStatType() {
    showDialog(
      context: context,
      builder: (context) => _AddStatTypeDialog(
        onAdd: (newStatType) {
          setState(() {
            statTypes.add(newStatType);
          });
          widget.onStatTypesChanged(statTypes);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Technical Performance Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: statTypes.length,
        itemBuilder: (context, index) {
          final stat = statTypes[index];
          return Card(
            child: ListTile(
              title: Text(stat.label),
              subtitle: Text('Key: ${stat.key}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _EditStatTypeDialog(
                      statType: stat,
                      onUpdate: (updated) {
                        _editStatType(index, updated);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStatType,
        tooltip: 'Add new stat type',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EditStatTypeDialog extends StatefulWidget {
  final StatType statType;
  final Function(StatType) onUpdate;

  const _EditStatTypeDialog({
    required this.statType,
    required this.onUpdate,
  });

  @override
  State<_EditStatTypeDialog> createState() => _EditStatTypeDialogState();
}

class _EditStatTypeDialogState extends State<_EditStatTypeDialog> {
  late TextEditingController keyController;
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController(text: widget.statType.key);
    labelController = TextEditingController(text: widget.statType.label);
  }

  @override
  void dispose() {
    keyController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Stat Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: 'Key'),
            enabled: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(StatType(
              key: widget.statType.key,
              label: labelController.text,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddStatTypeDialog extends StatefulWidget {
  final Function(StatType) onAdd;

  const _AddStatTypeDialog({required this.onAdd});

  @override
  State<_AddStatTypeDialog> createState() => _AddStatTypeDialogState();
}

class _AddStatTypeDialogState extends State<_AddStatTypeDialog> {
  late TextEditingController keyController;
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController();
    labelController = TextEditingController();
  }

  @override
  void dispose() {
    keyController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stat Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: 'Key (camelCase)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Display Label'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(StatType(
              key: keyController.text,
              label: labelController.text,
            ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
