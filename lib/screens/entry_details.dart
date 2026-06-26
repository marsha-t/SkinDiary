import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/services/storage_entry.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';
import 'package:skin_diary/navigation/entry_navigation_result.dart';

class EntryDetailsScreen extends StatefulWidget {
  final SkinEntry entry;

  const EntryDetailsScreen({super.key, required this.entry});

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen>
{
  late SkinEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _editEntry() async {
    final result = await Navigator.push<EntryNavigationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditEntryScreen(existingEntry: _entry)
      )
    );

    if (!mounted || result == null) return;

    switch (result.action) {
      case EntryNavigationAction.saved:
        setState(() => _entry = result.entry);
        break;
      case EntryNavigationAction.deleted:
        Navigator.pop(context, result);
        break;
    }
  }
  
  Future<void> _deleteEntry() async {
    final confirm = await showDeleteEntryConfirmationDialog(context);
    if (confirm) {
      await StorageEntry.deleteEntryRecord(_entry.id);
      if (!mounted) return;
      Navigator.pop(
        context, 
        EntryNavigationResult.deleted(_entry),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, y - h:mm a').format(_entry.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
          )
        ]
      ),
      body: SafeArea(
        child:SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: formattedDate),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Rating: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${_entry.rating}'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Tags: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _entry.tags.join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Notes : ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _entry.notes),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_entry.photos.isNotEmpty)
              const Text('Photos: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _entry.photos.map((photo) {
                  final file = File(photo['path']!);
                  final label = photo['label'] ?? '';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      file.existsSync()
                          ? Image.file(
                              file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                      Text(label),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      )
    );
  }
}