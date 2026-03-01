import 'package:flutter/material.dart';
import '../models/match_entry.dart';

class PlayerListPanel extends StatelessWidget {
  final List<Player> players;
  final int? selectedPlayerId;
  final Function(Player) onPlayerSelected;
  final VoidCallback onAddPlayer;

  const PlayerListPanel({
    Key? key,
    required this.players,
    this.selectedPlayerId,
    required this.onPlayerSelected,
    required this.onAddPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final isSelected = player.id == selectedPlayerId;

              return Container(
                color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                child: ListTile(
                  dense: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${player.number}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.position.isNotEmpty ? player.position : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => onPlayerSelected(player),
                  selected: isSelected,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(screenWidth > 600 ? 12.0 : 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddPlayer,
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 12 : 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
