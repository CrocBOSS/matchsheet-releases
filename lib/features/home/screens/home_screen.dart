import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../sports/soccer/screens/soccer_screen.dart';
import '../../sports/basketball/screens/basketball_screen.dart';
import '../../training/screens/training_player_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleAppExit(context);
      },
      child: _buildBody(context),
    );
  }

  Future<void> _handleAppExit(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit App?', style: TextStyle(fontSize: 16)),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                SystemNavigator.pop();
              },
              child: const Text('Exit', style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final sports = [
      {
        "title": "Soccer",
        "icon": Icons.sports_soccer,
        "color": Colors.green,
        "enabled": true,
      },
      {
        "title": "Basketball",
        "icon": Icons.sports_basketball,
        "color": Colors.orange,
        "enabled": true,
      },
      {
        "title": "Training Mode",
        "icon": Icons.school,
        "color": Colors.purple,
        "enabled": true,
        "isTraining": true,
      },
      {
        "title": "American Football",
        "icon": Icons.sports_football,
        "color": Colors.brown,
        "enabled": false,
      },
      {
        "title": "Handball",
        "icon": Icons.sports_handball,
        "color": Colors.deepPurple,
        "enabled": false,
      },
      {
        "title": "Volleyball",
        "icon": Icons.sports_volleyball,
        "color": Colors.blue,
        "enabled": false,
      },
      {
        "title": "Table Tennis",
        "icon": Icons.sports_tennis,
        "color": Colors.red,
        "enabled": false,
      },
      {
        "title": "Long Tennis",
        "icon": Icons.sports_tennis,
        "color": Colors.teal,
        "enabled": false,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Pep Match Sheet"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome 👋",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Choose Your Sport",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 32),

            /// Modern Grid
            Expanded(
              child: GridView.builder(
                itemCount: sports.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isMobile ? 2.8 : 2.2,
                ),
                itemBuilder: (context, index) {
                  final sport = sports[index];

                  return _ModernSportCard(
                    title: sport["title"] as String,
                    icon: sport["icon"] as IconData,
                    color: sport["color"] as Color,
                    enabled: sport["enabled"] as bool,
                    onTap: () {
                      if (sport["title"] == "Soccer") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SoccerScreen(),
                          ),
                        );
                      } else if (sport["title"] == "Basketball") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BasketballScreen(),
                          ),
                        );
                      } else if (sport["title"] == "Training Mode") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrainingPlayerSelectionScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("${sport["title"]} tracking coming soon!"),
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ModernSportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: enabled ? color : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: enabled ? null : Colors.grey,
                    ),
              ),
            ),
            if (!enabled)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Coming Soon",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            if (enabled)
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}