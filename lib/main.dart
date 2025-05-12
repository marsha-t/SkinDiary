import 'package:flutter/material.dart';
import 'package:skin_diary/screens/home.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';
import 'package:skin_diary/screens/history.dart';
import 'package:skin_diary/screens/shelf.dart';

void main() {
  runApp(const SkinDiary());
}

/// Sets up:
///   - title
///   - theme
///   - routes
///   - remove debug banner
class SkinDiary extends StatelessWidget
{
  const SkinDiary({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SkinDiary", 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF9C5D1))
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/add_entry': (context) => AddEditEntryScreen(),
        '/history': (context) => HistoryScreen(),
        '/product_shelf': (context) => ShelfScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
