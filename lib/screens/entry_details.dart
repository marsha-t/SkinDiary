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

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  // State
  late SkinEntry _entry;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  // Entry actions
  Future<void> _editEntry() async {
    final result = await Navigator.push<EntryNavigationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditEntryScreen(existingEntry: _entry),
      ),
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
      Navigator.pop(context, EntryNavigationResult.deleted(_entry));
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, y - h:mm a').format(_entry.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editEntry),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteEntry),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', formattedDate),
              _buildDetailRow('Rating', '${_entry.rating}'),
              if (_entry.tags.isNotEmpty)
                _buildDetailRow('Tags', _entry.tags.join(', ')),
              if (_entry.notes.trim().isNotEmpty)
                _buildDetailRow('Notes', _entry.notes),
              _buildProductsUsedSection(),
              _buildPhotosSection(),
            ],
          ),
        ),
      ),
    );
  }

  // UI builders
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsUsedSection() {
    if (_entry.productsUsed.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Products Used:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          children:
              _entry.productsUsed.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                final brand = product.brand?.trim() ?? '';
                final label =
                    brand.isEmpty ? product.name : '$brand - ${product.name}';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(label),
                );
              }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotosSection() {
    if (_entry.photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _entry.photos.map((photo) {
                final file = File(photo.path);
                final label = photo.label;

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
    );
  }
}
