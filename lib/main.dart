// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/slot_analyzer_screen.dart';

void main() {
  runApp(SlotAnalyzerApp());
}

class SlotAnalyzerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '設定判別ツール',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SlotAnalyzerScreen(),
    );
  }
}