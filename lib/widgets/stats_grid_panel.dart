import 'package:flutter/material.dart';
import '../models/match_entry.dart';
import '../utils/dialog_helpers.dart';
import 'stat_counter_box.dart';

class StatsGridPanel extends StatelessWidget {
  final Player? selectedPlayer;
  final Function(String, int) onStatChanged;
  final Function(String) onCommentChanged;

  const StatsGridPanel({
    Key? key,
    this.selectedPlayer,
    required this.onStatChanged,
    required this.onCommentChanged,
  }) : super(key: key);

  void _showCommentDialog(BuildContext context) {
    DialogHelpers.showTextInputDialog(
      context: context,
      title: 'Edit Comments',
      initialText: selectedPlayer?.comments ?? '',
      labelText: 'Enter comments...',
      maxLines: 5,
      onSave: onCommentChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (selectedPlayer == null) {
      return Center(
        child: Text(
          'Select a player to view statistics',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth > 600 ? 16 : 8),
      child: Column(
        children: [
          Text(
            '${selectedPlayer!.number} - ${selectedPlayer!.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCounterBox(
                label: 'Completed\nPasses',
                value: selectedPlayer!.completedPasses,
                onIncrement: () => onStatChanged('completedPasses', selectedPlayer!.completedPasses + 1),
                onDecrement: () => onStatChanged('completedPasses', (selectedPlayer!.completedPasses - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Interceptions',
                value: selectedPlayer!.interceptions,
                onIncrement: () => onStatChanged('interceptions', selectedPlayer!.interceptions + 1),
                onDecrement: () => onStatChanged('interceptions', (selectedPlayer!.interceptions - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Turnovers',
                value: selectedPlayer!.turnovers,
                onIncrement: () => onStatChanged('turnovers', selectedPlayer!.turnovers + 1),
                onDecrement: () => onStatChanged('turnovers', (selectedPlayer!.turnovers - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Tackles',
                value: selectedPlayer!.tackles,
                onIncrement: () => onStatChanged('tackles', selectedPlayer!.tackles + 1),
                onDecrement: () => onStatChanged('tackles', (selectedPlayer!.tackles - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Fouls',
                value: selectedPlayer!.fouls,
                onIncrement: () => onStatChanged('fouls', selectedPlayer!.fouls + 1),
                onDecrement: () => onStatChanged('fouls', (selectedPlayer!.fouls - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Shots On\nTarget',
                value: selectedPlayer!.shotsOnTarget,
                onIncrement: () => onStatChanged('shotsOnTarget', selectedPlayer!.shotsOnTarget + 1),
                onDecrement: () => onStatChanged('shotsOnTarget', (selectedPlayer!.shotsOnTarget - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Assists',
                value: selectedPlayer!.assists,
                onIncrement: () => onStatChanged('assists', selectedPlayer!.assists + 1),
                onDecrement: () => onStatChanged('assists', (selectedPlayer!.assists - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Goals',
                value: selectedPlayer!.goals,
                onIncrement: () => onStatChanged('goals', selectedPlayer!.goals + 1),
                onDecrement: () => onStatChanged('goals', (selectedPlayer!.goals - 1).clamp(0, double.infinity).toInt()),
              ),
              StatCounterBox(
                label: 'Yellow\nCards',
                value: selectedPlayer!.yellowCards,
                onIncrement: () => onStatChanged('yellowCards', selectedPlayer!.yellowCards + 1),
                onDecrement: () => onStatChanged('yellowCards', (selectedPlayer!.yellowCards - 1).clamp(0, double.infinity).toInt()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCommentDialog(context),
              icon: const Icon(Icons.comment),
              label: const Text('Edit Comments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (selectedPlayer!.comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Comments: ${selectedPlayer!.comments}',
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
