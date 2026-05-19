import 'package:flutter/material.dart';
import '../../models/match_entry.dart';
import '../../models/stat_type.dart';

class MatchSheetScreen extends StatefulWidget {
  final List<Player> players;
  final List<StatType> statTypes;
  final String teamName;

  const MatchSheetScreen({
    Key? key,
    required this.players,
    required this.statTypes,
    required this.teamName,
  }) : super(key: key);

  @override
  State<MatchSheetScreen> createState() => _MatchSheetScreenState();
}

class _MatchSheetScreenState extends State<MatchSheetScreen> {
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  int _getFirstHalfStatValue(Player player, String statKey) {
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

  int _getSecondHalfStatValue(Player player, String statKey) {
    return player.secondHalfStats[statKey] ?? 0;
  }

  int _getTotalStatValue(Player player, String statKey) {
    return _getFirstHalfStatValue(player, statKey) + _getSecondHalfStatValue(player, statKey);
  }

  void _showPlayerInfoDialog(Player player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Player Info', style: TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jersey #${player.number}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${player.name}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Position: ${player.position.isNotEmpty ? player.position : '-'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void _showCommentsDialog(Player player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('#${player.number}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(player.position.isNotEmpty ? player.position : '-', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(player.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.comments.isNotEmpty ? player.comments : 'No comments',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontSize: 12)),
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
    final playerWidth = screenWidth > 1200 ? 165.0 : screenWidth > 600 ? 120.0 : 105.0;
    final statColumnWidth = screenWidth > 1200 ? 85.0 : screenWidth > 600 ? 70.0 : 60.0;
    final commentColumnWidth = screenWidth > 1200 ? 100.0 : screenWidth > 600 ? 70.0 : 55.0;

    // Responsive font sizes
    final playerNameFontSize = screenWidth > 1200 ? 14.0 : screenWidth > 600 ? 12.0 : 10.0;
    final playerNumberFontSize = screenWidth > 1200 ? 24.0 : screenWidth > 600 ? 20.0 : 16.0;
    final statValueFontSize = screenWidth > 1200 ? 14.0 : screenWidth > 600 ? 12.0 : 10.0;

    // AppBar sizing
    final appBarHeight = isLandscape ? 45.0 : 56.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: Text('${widget.teamName} - Read Only', style: TextStyle(fontSize: isLandscape ? 12 : 16)),
        elevation: 0,
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
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.teamName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth > 600 ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Match Summary',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth > 600 ? 12 : 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Player Rows
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                final player = widget.players[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Player Name Column
                      GestureDetector(
                        onTap: () => _showPlayerInfoDialog(player),
                        child: SizedBox(
                          width: playerWidth,
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
                                    color: Colors.blue,
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
                                  style: TextStyle(
                                    fontSize: playerNameFontSize,
                                    color: Colors.blue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Stat Values + Comments + Rating
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._buildStatValues(player, statColumnWidth, statValueFontSize),
                              // Comments Column
                              GestureDetector(
                                onTap: player.comments.isNotEmpty ? () => _showCommentsDialog(player) : null,
                                child: SizedBox(
                                  width: commentColumnWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Comments',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: statValueFontSize * 0.9,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          player.comments.isNotEmpty ? player.comments : '-',
                                          style: TextStyle(
                                            fontSize: statValueFontSize * 0.8,
                                            color: player.comments.isNotEmpty ? Colors.blue : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Rating Column
                              SizedBox(
                                width: commentColumnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Rating',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: statValueFontSize * 0.9,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        player.rating > 0 ? '${player.rating}/10' : '-',
                                        style: TextStyle(
                                          fontSize: statValueFontSize,
                                          color: player.rating > 0 ? Colors.orange : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
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
    );
  }



  List<Widget> _buildStatValues(Player player, double columnWidth, double statValueFontSize) {
    return widget.statTypes.map((stat) {
      final totalValue = _getTotalStatValue(player, stat.key);
      return SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: statValueFontSize * 0.9,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$totalValue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: statValueFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '(1st: ${_getFirstHalfStatValue(player, stat.key)}, 2nd: ${_getSecondHalfStatValue(player, stat.key)})',
                style: TextStyle(
                  fontSize: statValueFontSize * 0.5,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
