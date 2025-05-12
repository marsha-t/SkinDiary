import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/screens/select_product.dart';
import 'package:skin_diary/services/storage_entry.dart';
import 'package:skin_diary/widgets/photo_label_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';



class AddEditEntryScreen extends StatefulWidget {
  final SkinEntry? existingEntry;
  
  const AddEditEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late int _rating;
  late List<String> _tags;
  late String _notes;
  List<Map<String, String>> _labeledPhotos = [];
  String _selectedLabel = 'Full Face';
  List<Product> _selectedProducts = [];

  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _date = entry?.date ?? DateTime.now();
    _rating = entry?.rating ?? 3;
    _tags = entry?.tags ?? [];
    _notes = entry?.notes ?? '';
    _labeledPhotos = entry?.photos ?? [];
    _selectedProducts = entry?.productsUsed ?? [];
    _tagsController.text = _tags.join(', ');
    _notesController.text = _notes;
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String> saveImagePermanently(String tempImagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(tempImagePath);
    final newPath = path.join(directory.path, fileName);
    final newImage = await File(tempImagePath).copy(newPath);
    return newImage.path;
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final id = widget.existingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final entry = SkinEntry(
      id: id,
      date: _date,
      photos: _labeledPhotos,
      rating: _rating,
      tags: _tags,
      notes: _notes,
      productsUsed: _selectedProducts,
    );

    await StorageEntry.saveEntry(entry);
    if (mounted) Navigator.pop(context, entry);
  }
  
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
        final savedPath = await saveImagePermanently(pickedFile.path);
        setState(() {
          _labeledPhotos.add({
            'path': savedPath,
            'label': _selectedLabel,
          });
        });
      }
    }
  }

  Future<void> _selectProducts() async {
    final result = await Navigator.push<List<Product>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProductScreen(
          initialSelection: _selectedProducts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProducts = result;
      });
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
        await StorageEntry.deleteEntry(widget.existingEntry!.id);
        if (!mounted) return;
        Navigator.pop(context, deleted);
      }
    }
  }

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
              Text('Products Used:', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                children: _selectedProducts.map((p) => Chip(label: Text(p.name))).toList(),
              ),
              const SizedBox(height: 10),
              _buildSaveDeleteButtons(widget.existingEntry != null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagField() {
    return TextFormField(
      controller: _tagsController,
      maxLines: 2,
      decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
      onSaved: (value) => _tags = value!.split(',').map((e) => e.trim()).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Notes'),
      onSaved: (value) => _notes = value ?? '',
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
                'Date: ${DateFormat('MMMM d, yyyy – h:mm a').format(_date)}',
              ),
            ),
            TextButton(
              onPressed: _selectDateTime,
              child: const Text('Change'),
            ),
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
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Add Photo'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _labeledPhotos.map((photo) {
            final file = File(photo['path']!);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                file.existsSync()
                    ? Image.file(file, width: 100, height: 100, fit: BoxFit.cover)
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                Text(photo['label'] ?? ''),
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
        ElevatedButton(
          onPressed: _saveEntry,
          child: const Text('Save Entry'),
        ),
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
