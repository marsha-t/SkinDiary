import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/services/storage.dart';
import 'package:skin_diary/widgets/photo_label_dropdown.dart';

class AddEditEntryScreen extends StatefulWidget {
  final SkinEntry? existingEntry;
  
  const AddEditEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  late DateTime _date;
  late int _rating;
  late List<String> _tags;
  final _tagsController = TextEditingController();
  late String _notes;
  final _notesController = TextEditingController();
  List<Map<String, String>> _labeledPhotos = [];
  String _selectedLabel = 'Full Face';

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _date = entry?.date ?? DateTime.now();
    _rating = entry?.rating ?? 3;
    _tags = entry?.tags ?? [];
    _notes = entry?.notes ?? '';
    _labeledPhotos = entry?.photos ?? [];
    _notesController.text = _notes;
    _tagsController.text = _tags.join(', ');
  }

  Future<void>  _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Upload Photo'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Take Photo'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Choose from Gallery'),
          )
        ],
      )
    );
    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _labeledPhotos.add({
            'path': pickedFile.path,
            'label': _selectedLabel,
          });
        });
      }
    }
  }

  Future<void>  _saveEntry() async {
    final id = widget.existingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final entry = SkinEntry(
      id: id, 
      date: _date, 
      photos: _labeledPhotos, 
      rating: _rating, 
      tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
      notes: _notesController.text,
    );
    await StorageService.saveEntry(entry);
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  Future<void> _deleteEntry() async {
    if (widget.existingEntry == null) {
      Navigator.pop(context);
    } 
    else {
      final confirm = await showDeleteConfirmationDialog(context);
      if (confirm) {
        final deleted = widget.existingEntry!;
        await StorageService.deleteEntry(widget.existingEntry!.id);
        if (!mounted) return;
        Navigator.pop(context, deleted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add/Edit Entry')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_date.toLocal()}'), // TODO allow edit of date
            const SizedBox(height: 10),
            Text('Rating: ${_rating.toInt()}'),
            Slider(
              value: _rating.toDouble(),
              min: 1, 
              max: 5, 
              divisions: 4, 
              label: _rating.toString(), 
              onChanged: (value) {
                setState(() => _rating = value.toInt());
              }),
            const SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 10),
            PhotoLabelDropdown(
              onLabelSelected: (label) {
                _selectedLabel = label;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage, 
              child: const Text('Add Photo')
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _labeledPhotos.map((photo) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    File(photo['path']!),
                    width: 100, 
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Text(photo['label'] ?? ''),
                ],
              )).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveEntry, 
              child: const Text('Save Entry')
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteEntry, 
              child: const Text('Delete Entry')
            ),
          ],
        ),
      )
    );
  }
}