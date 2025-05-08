import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/services/storage.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/utils/snackbar.dart';
import 'package:skin_diary/screens/entry_details.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SkinEntry> allEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final loadedEntries = await StorageService.getAllEntries();
    if (!mounted) return;
    setState(() => allEntries = loadedEntries);
  }
  
  Future<void> _deleteEntry(String id) async {
    await StorageService.deleteEntry(id);
    if (!mounted) return;
    _loadEntries();
  }

  Future<void> _navigateToDetails(SkinEntry entry) async {
    final returnedEntry = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => EntryDetailsScreen(entry: entry)),
    );
    if (!mounted) return;
    _loadEntries();
    if (returnedEntry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildUndoDeleteSnackBar(
          entry: returnedEntry,
          onUndo: () async {
            setState(() {
              allEntries.add(returnedEntry);
              allEntries.sort((a, b) => b.date.compareTo(a.date));
            });
            await StorageService.saveEntry(returnedEntry);
          },
        ),
      );
    }
  }

Future<void> _navigateToAdd() async {
  final returnedEntry = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddEditEntryScreen()),
  );

  if (!mounted) return;

  if (returnedEntry != null) {
    setState(() {
      allEntries.add(returnedEntry);
      allEntries.sort((a, b) => b.date.compareTo(a.date));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New entry added')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: allEntries.isEmpty
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: allEntries.length,
            itemBuilder: (context, index) {
            final entry = allEntries[index];
            final formatted = DateFormat('h:mm a').format(entry.date);
            final photo = entry.photos.isNotEmpty ? entry.photos.first['path'] : null;

            return Dismissible(
              key: ValueKey(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) => showDeleteConfirmationDialog(context),
              onDismissed: (_) => _deleteEntry(entry.id),
              child: ListTile(
              leading: photo != null 
                ? Image.file(
                  File(photo),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.image_not_supported),
              title: Text('Time: $formatted'),
              subtitle: Text('Rating: ${entry.rating} | Tags: ${entry.tags.join(', ')}'),
              onTap: () => _navigateToDetails(entry)
              )
          );
        },
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}