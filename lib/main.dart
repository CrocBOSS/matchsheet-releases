import 'package:flutter/material.dart';
import 'screens/shared/home_screen.dart';
import 'screens/training/training_screen.dart';
import 'models/training_player.dart';

void main() {
  runApp(const MatchSheetApp());
}

class MatchSheetApp extends StatelessWidget {
  const MatchSheetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pep Match Sheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        // Handle dynamic routes
        if (settings.name == '/training') {
          final player = settings.arguments as TrainingPlayer;
          return MaterialPageRoute(
            builder: (context) => TrainingScreen(player: player),
          );
        }
        return null;
      },
    );
  }
}
