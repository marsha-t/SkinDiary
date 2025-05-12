import 'dart:io';
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_diary/services/database_service.dart';
import 'package:skin_diary/models/skin_entry.dart';

class StorageEntry {
  static const _key = 'skin_entries';
  
  static Future<void> saveEntry(SkinEntry entry) async {
    final entries = await getAllEntries();
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex != -1) {
      entries[existingIndex] = entry;
    } 
    else {
      entries.add(entry);
    }
  final entryMap = entries.map((e) => e.toMap()).toList();
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setString(_key, jsonEncode(entryMap));
  await DatabaseService.setPreference(_key, jsonEncode(entryMap));
  }
  
  static Future<List<SkinEntry>> getAllEntries() async {
    // final prefs = await SharedPreferences.getInstance();
    // final entries = prefs.getString(_key);
    final entries = await DatabaseService.getPreference(_key);
    if (entries == null) return [];
    final List decoded = jsonDecode(entries);
    return decoded.map((e) => SkinEntry.fromMap(e)).toList();
  }

  static Future<void> deleteEntry(String id) async {
    final entries = await getAllEntries();
    SkinEntry? entryToDelete;
    try {
      entryToDelete = entries.firstWhere((e) => e.id == id);
    } catch (_) {
      entryToDelete = null;
    }
    if (entryToDelete != null) {
      for (final photo in entryToDelete.photos) {
        final path = photo['path'];
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
      entries.remove(entryToDelete);
    }
    // entries.removeWhere((e) => e.id == id);
    final entryMap = entries.map((e) => e.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(entryMap));
  }

  static Future<List<SkinEntry>> getTodayEntries() async {
    final all = await getAllEntries();
    final now = DateTime.now();
    return all.where((e) =>
      e.date.year == now.year &&
      e.date.month == now.month && 
      e.date.day == now.day
    ).toList();
  }
}