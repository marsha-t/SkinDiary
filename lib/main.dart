import 'package:flutter/material.dart';
import 'package:skin_diary/app/app_routes.dart';

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
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
