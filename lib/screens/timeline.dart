import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/services/storage_entry.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/utils/snackbar.dart';
import 'package:skin_diary/screens/entry_details.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';
import 'package:skin_diary/navigation/entry_navigation_result.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // State
  List<SkinEntry> _allEntries = [];

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // Data loading
  Future<void> _loadEntries() async {
    final loadedEntries = await StorageEntry.getAllEntries();

    if (!mounted) return;

    setState(() => _allEntries = loadedEntries);
  }

  // Navigation
  Future<void> _navigateToDetails(SkinEntry entry) async {
    final result = await Navigator.push<EntryNavigationResult>(
      context,
      MaterialPageRoute(builder: (context) => EntryDetailsScreen(entry: entry)),
    );

    if (!mounted) return;

    // Reload regardless of result. EntryDetailsScreen may update an entry, stay open, then return null when the user backs out
    await _loadEntries();

    if (result != null && result.action == EntryNavigationAction.deleted) {
      _showUndoDeleteEntrySnackBar(result.entry);
    }
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<EntryNavigationResult>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditEntryScreen()),
    );

    if (!mounted || result == null) return;

    await _loadEntries();
  }

  // Entry actions
  Future<void> _deleteEntry(String id) async {
    final deletedEntry = _allEntries.firstWhere((entry) => entry.id == id);

    await StorageEntry.deleteEntryRecord(id);

    if (!mounted) return;

    await _loadEntries();

    _showUndoDeleteEntrySnackBar(deletedEntry);
  }

  void _showUndoDeleteEntrySnackBar(SkinEntry entry) {
    ScaffoldMessenger.of(context).showSnackBar(
      buildUndoSnackBar(
        message: 'Deleted entry from ${DateFormat.yMMMd().format(entry.date)}',
        onUndo: () async {
          await StorageEntry.saveEntry(entry);
          if (mounted) await _loadEntries();
        },
      ),
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: SafeArea(
        child:
            _allEntries.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No entries yet', style: TextStyle(fontSize: 16)),
                      Text('Start by adding a new skin log!'),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _allEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _allEntries[index];
                    final formatted = DateFormat(
                      'MMM d, y - h:mm a',
                    ).format(entry.date);
                    final photoPath =
                        entry.photos.isNotEmpty
                            ? entry.photos.first.path
                            : null;
                    final photoFile =
                        photoPath != null ? File(photoPath) : null;
                    final hasPhotoFile =
                        photoFile != null && photoFile.existsSync();

                    return Dismissible(
                      key: ValueKey(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss:
                          (direction) =>
                              showDeleteEntryConfirmationDialog(context),
                      onDismissed: (_) => _deleteEntry(entry.id),
                      child: ListTile(
                        leading:
                            hasPhotoFile
                                ? Image.file(
                                  photoFile,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.image_not_supported),
                        title: Text(formatted),
                        subtitle: Text(
                          'Rating: ${entry.rating} | Tags: ${entry.tags.join(', ')}',
                        ),
                        onTap: () => _navigateToDetails(entry),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
