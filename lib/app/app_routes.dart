import 'package:flutter/material.dart'; // Needed for WidgetBuilder
import 'package:skin_diary/screens/home.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';
import 'package:skin_diary/screens/history.dart';
import 'package:skin_diary/screens/shelf.dart';

// Set up route names
class AppRoutes {
    static const home = '/';
    static const addEntry = '/add_entry';
    static const history = '/history';
    static const productShelf = '/product_shelf';

    static Map<String, WidgetBuilder> routes = {
        home: (context) => const HomeScreen(),
        addEntry: (context) => const AddEditEntryScreen(),
        history: (context) => const HistoryScreen(),
        productShelf: (context) => const ShelfScreen(),
    };
}