import 'dart:io';
import 'dart:convert';
import 'package:skin_diary/services/database_service.dart';
import 'package:skin_diary/models/skin_entry.dart';

class StorageEntry {
  static const _key = 'skin_entries';

  static Future<void> saveEntry(SkinEntry entry) async {
    final entries = await getAllEntries();
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);
    if (existingIndex != -1) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }
    final entryMap = entries.map((e) => e.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(entryMap));
  }

  static Future<List<SkinEntry>> getAllEntries() async {
    final entries = await DatabaseService.getPreference(_key);
    if (entries == null) return [];

    final List decoded = jsonDecode(entries);
    final parsedEntries = decoded.map((e) => SkinEntry.fromMap(e)).toList();

    parsedEntries.sort((a, b) => b.date.compareTo(a.date));

    return parsedEntries;
  }

  static SkinEntry? _findEntryById(List<SkinEntry> entries, String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }

    return null;
  }

  static Future<void> deleteEntryRecord(String id) async {
    final entries = await getAllEntries();
    final entryToDelete = _findEntryById(entries, id);

    if (entryToDelete == null) return;

    entries.removeWhere((entry) => entry.id == id);

    final entryMap = entries.map((e) => e.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(entryMap));
  }

  static Future<void> deleteEntryPhotoFiles(SkinEntry entry) async {
    for (final photo in entry.photos) {
      final file = File(photo.path);
      
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<List<SkinEntry>> getTodayEntries() async {
    final all = await getAllEntries();
    final now = DateTime.now();

    return all
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .toList();
  }
}
