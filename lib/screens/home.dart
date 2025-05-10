import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/services/storage_entry.dart';
import 'package:skin_diary/models/skin_entry.dart';
import 'package:skin_diary/utils/snackbar.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/screens/add_edit_entry.dart';
import 'package:skin_diary/screens/history.dart';
import 'package:skin_diary/screens/entry_details.dart';
import 'package:skin_diary/screens/shelf.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SkinEntry> _todayEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void>  _loadEntries() async {
    final newToday = await StorageEntry.getTodayEntries();
    if (!mounted) return;
    if (!listEquals(_todayEntries, newToday)) {
      setState(() {
        _todayEntries = newToday;
      });
    }
  }
  
  Future<void> _navigateToAdd() async {
    final returnedEntry = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const AddEditEntryScreen()),
    );
    if (!mounted) return;
    _loadEntries();
    if (returnedEntry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildUndoDeleteSnackBar(
          entry: returnedEntry,
          onUndo: () async {
            setState(() {
              _todayEntries.add(returnedEntry);
              _todayEntries.sort((a, b) => b.date.compareTo(a.date));
            });
            await StorageEntry.saveEntry(returnedEntry);
            if (mounted) _loadEntries();
          },
        ),
      );
    }
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
              _todayEntries.add(returnedEntry);
              _todayEntries.sort((a, b) => b.date.compareTo(a.date));
            });
            await StorageEntry.saveEntry(returnedEntry);
            if (mounted) _loadEntries();
          },
        ),
      );
    }
  }

  Future<void>  _navigateToHistory() async {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
    if (!mounted) return;
    _loadEntries();
  }

  Future<void> _navigateToShelf() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShelfScreen()),
    );
  }

  Future<void> _deleteEntry(String id) async {
    final deletedEntry = _todayEntries.firstWhere((e) => e.id == id);
    await StorageEntry.deleteEntry(id);
    if (!mounted) return;
    setState(() {
      _todayEntries.removeWhere((entry) => entry.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      buildUndoDeleteSnackBar(
        entry: deletedEntry,
        onUndo: () async {
          setState(() {
            _todayEntries.add(deletedEntry);
            _todayEntries.sort((a, b) => b.date.compareTo(a.date));
          });
          await StorageEntry.saveEntry(deletedEntry);
          if (mounted) _loadEntries();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasEntries = _todayEntries.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('Skin Diary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: hasEntries ? _buildEntryList() : _buildEmptyState()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEntryList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Today's Entries", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Expanded(child: _buildEntryListView()),
      _buildActionButtons(),
    ],
  );

  Widget _buildEntryListView() => ListView.builder(
    itemCount: _todayEntries.length,
    itemBuilder: (context, index) {
      final entry = _todayEntries[index];
      final formatted = DateFormat('h:mm a').format(entry.date);
      return Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissibleBackground(),
        confirmDismiss: (direction) => showDeleteConfirmationDialog(context),
        onDismissed: (_) => _deleteEntry(entry.id),
        child: ListTile(
          title: Text('Time: $formatted'),
          subtitle: Text('Rating: ${entry.rating} | Tags: ${entry.tags.join(', ')}'),
          onTap: () => _navigateToDetails(entry),
        ),
      );
    },
  );

  Widget _buildActionButtons() => Column(
    children: [
      ElevatedButton(
        onPressed: _navigateToHistory,
        child: const Text('View History'),
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: _navigateToShelf,
        child: const Text('My Product Shelf'),
      ),
    ],
  );

  Widget _buildDismissibleBackground() => Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
        const SizedBox(height: 10),
        const Text('No entries yet today', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        _buildActionButtons(),
      ],
    ),
  );

  
}