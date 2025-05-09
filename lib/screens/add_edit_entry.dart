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
  List<Product> _selectedProducts = [];

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

  @override
  void dispose() {
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
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
        setState(() {
          _labeledPhotos.add({
            'path': pickedFile.path,
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

  Future<void>  _saveEntry() async {
    final id = widget.existingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final entry = SkinEntry(
      id: id, 
      date: _date, 
      photos: _labeledPhotos, 
      rating: _rating, 
      tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
      notes: _notesController.text,
      productsUsed: _selectedProducts,
    );
    await StorageEntry.saveEntry(entry);
    if (mounted) {
      Navigator.pop(context, entry);
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
            Text('Products Used:', style: TextStyle(fontWeight: FontWeight.bold)),
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


  Widget _buildTagField() {
    return TextField(
      controller: _tagsController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Notes'),
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
            return Column(
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text(widget.existingEntry == null ? 'Add Entry' : 'Edit Entry')),
  //     body: SingleChildScrollView(
  //       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Date: ${_date.toLocal()}'), // TODO allow edit of date
  //           const SizedBox(height: 10),
  //           Text('Rating: ${_rating.toInt()}'),
  //           Slider(
  //             value: _rating.toDouble(),
  //             min: 1, 
  //             max: 5, 
  //             divisions: 4, 
  //             label: _rating.toString(), 
  //             onChanged: (value) {
  //               setState(() => _rating = value.toInt());
  //             }),
  //           const SizedBox(height: 10),
  //           TextField(
  //             controller: _tagsController,
  //             maxLines: 3,
  //             decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
  //           ),
  //           const SizedBox(height: 10),
  //           TextField(
  //             controller: _notesController,
  //             maxLines: 3,
  //             decoration: const InputDecoration(labelText: 'Notes'),
  //           ),
  //           const SizedBox(height: 10),
  //           PhotoLabelDropdown(
  //             onLabelSelected: (label) {
  //               _selectedLabel = label;
  //             },
  //           ),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: _pickImage, 
  //             child: const Text('Add Photo')
  //           ),
  //           const SizedBox(height: 10),
  //           Wrap(
  //             spacing: 8,
  //             children: _labeledPhotos.map((photo) => Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Image.file(
  //                   File(photo['path']!),
  //                   width: 100, 
  //                   height: 100,
  //                   fit: BoxFit.cover,
  //                 ),
  //                 Text(photo['label'] ?? ''),
  //               ],
  //             )).toList(),
  //           ),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: _saveEntry, 
  //             child: const Text('Save Entry')
  //           ),
  //           const SizedBox(height: 10),
  //           if (widget.existingEntry != null) 
  //             ElevatedButton(
  //               onPressed: _deleteEntry, 
  //               child: const Text('Delete Entry')
  //             ),
  //         ],
  //       ),
  //     )
  //   );
  // }
}