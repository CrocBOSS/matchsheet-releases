import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
    );
  }
}
