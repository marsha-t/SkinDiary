import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/screens/select_product.dart';
import 'package:skin_diary/services/storage_entry.dart';
import 'package:skin_diary/widgets/photo_label_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:skin_diary/navigation/entry_navigation_result.dart';
import 'package:skin_diary/models/entry_photo.dart';
import 'package:skin_diary/constants/photo_labels.dart';

class AddEditEntryScreen extends StatefulWidget {
  final SkinEntry? existingEntry;

  const AddEditEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  // State
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late int _rating;
  late List<String> _tags;
  late String _notes;
  List<EntryPhoto> _photos = [];
  String _selectedLabel = photoLabels.first;
  List<Product> _selectedProducts = [];

  // Lifecycle
  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _date = entry?.date ?? DateTime.now();
    _rating = entry?.rating ?? 3;
    _tags = entry?.tags ?? [];
    _notes = entry?.notes ?? '';
    _photos = List<EntryPhoto>.from(entry?.photos ?? []);
    _selectedProducts = List<Product>.from(entry?.productsUsed ?? []);
  }

  // Persistence
  Future<String> _saveImagePermanently(String tempImagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(tempImagePath);
    final newPath = path.join(directory.path, fileName);
    final newImage = await File(tempImagePath).copy(newPath);
    return newImage.path;
  }

  // Entry actions
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    const uuid = Uuid();
    final id = widget.existingEntry?.id ?? uuid.v4();

    final entry = SkinEntry(
      id: id,
      date: _date,
      photos: _photos,
      rating: _rating,
      tags: _tags,
      notes: _notes,
      productsUsed: _selectedProducts,
    );

    await StorageEntry.saveEntry(entry);
    if (mounted) {
      Navigator.pop(context, EntryNavigationResult.saved(entry));
    }
  }

  Future<void> _deleteEntry() async {
    final entry = widget.existingEntry;
    if (entry == null) return;

    final confirm = await showDeleteEntryConfirmationDialog(context);
    if (confirm) {
      await StorageEntry.deleteEntryRecord(entry.id);
      if (!mounted) return;
      Navigator.pop(context, EntryNavigationResult.deleted(entry));
    }
  }

  // Date/time actions
  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // Photo actions
  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Upload Photo'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Take Photo'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Choose from Gallery'),
              ),
            ],
          ),
    );

    if (!mounted) return;

    if (source != null) {
      try {
        final pickedFile = await ImagePicker().pickImage(source: source);

        if (!mounted || pickedFile == null) return;

        String savedPath;

        try {
          savedPath = await _saveImagePermanently(pickedFile.path);
        } catch (error) {
          debugPrint('Image save error: $error');

          if (!mounted) return;

          _showPhotoError('Could not save photo. Please try again.');

          return;
        }

        if (!mounted) return;

        setState(() {
          _photos.add(EntryPhoto(path: savedPath, label: _selectedLabel));
        });
      } catch (error) {
        debugPrint('Image picker error: $error');

        if (!mounted) return;

        _showPhotoError(
          source == ImageSource.camera
              ? 'Could not take photo. Check camera permissions and try again.'
              : 'Could not choose photo. Check photo library permissions and try again.',
        );
      }
    }
  }

  void _showPhotoError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editPhotoLabel(int index) async {
    final selectedLabel = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Change photo label'),
          children:
              photoLabels.map((label) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, label),
                  child: Text(label),
                );
              }).toList(),
        );
      },
    );

    if (!mounted || selectedLabel == null) return;

    String finalLabel = selectedLabel;

    if (selectedLabel == customPhotoLabelOption) {
      final customLabel = await _askForCustomPhotoLabel();

      if (!mounted || customLabel == null) return;

      finalLabel = customLabel;
    }

    setState(() {
      _photos[index] = _photos[index].copyWith(label: finalLabel);
    });
  }

  Future<String?> _askForCustomPhotoLabel() async {
    String customLabel = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom photo label'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Left temple',
            ),
            onChanged: (value) {
              customLabel = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final trimmed = customLabel.trim();

                if (trimmed.isEmpty) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, trimmed);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Product actions
  Future<void> _selectProducts() async {
    final result = await Navigator.push<List<Product>>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SelectProductScreen(initialSelection: _selectedProducts),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _selectedProducts = result;
    });
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry == null ? 'Add Entry' : 'Edit Entry'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateAndRating(),
              const SizedBox(height: 10),
              _buildTagField(),
              const SizedBox(height: 10),
              _buildNotesField(),
              const SizedBox(height: 10),
              _buildPhotoSection(),
              const SizedBox(height: 10),
              Text(
                'Products Used:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _selectProducts,
                child: Text(
                  _selectedProducts.isEmpty
                      ? 'Select products used'
                      : '${_selectedProducts.length} product(s) selected',
                ),
              ),
              Wrap(
                spacing: 8,
                children:
                    _selectedProducts
                        .map((p) => Chip(label: Text(p.name)))
                        .toList(),
              ),
              const SizedBox(height: 10),
              _buildSaveDeleteButtons(widget.existingEntry != null),
            ],
          ),
        ),
      ),
    );
  }

  // UI builders
  Widget _buildTagField() {
    return TextFormField(
      initialValue: _tags.join(', '),
      maxLines: 2,
      decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
      onSaved: (value) {
        _tags =
            (value ?? '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      initialValue: _notes,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Notes'),
      onSaved: (value) => _notes = value?.trim() ?? '',
    );
  }

  Widget _buildDateAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Date: ${DateFormat('MMMM d, yyyy - h:mm a').format(_date)}',
              ),
            ),
            TextButton(onPressed: _selectDateTime, child: const Text('Change')),
          ],
        ),
        const SizedBox(height: 10),
        Text('Rating: $_rating'),
        Slider(
          value: _rating.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _rating.toString(),
          onChanged: (value) {
            setState(() => _rating = value.toInt());
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoLabelDropdown(onLabelSelected: (label) => _selectedLabel = label),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _pickImage, child: const Text('Add Photo')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children:
              _photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                final file = File(photo.path);

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
                    Text(photo.label),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit photo label',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPhotoLabel(index),
                        ),
                        IconButton(
                          tooltip: 'Remove photo from entry',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _photos.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveDeleteButtons(bool showDelete) {
    return Column(
      children: [
        ElevatedButton(onPressed: _saveEntry, child: const Text('Save Entry')),
        const SizedBox(height: 10),
        if (showDelete)
          ElevatedButton(
            onPressed: _deleteEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Entry'),
          ),
      ],
    );
  }
}
