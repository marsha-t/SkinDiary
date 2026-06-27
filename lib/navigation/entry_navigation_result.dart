import 'package:skin_diary/models/skin_entry.dart';

enum EntryNavigationAction { saved, deleted }

class EntryNavigationResult {
  final EntryNavigationAction action;
  final SkinEntry entry;

  const EntryNavigationResult({required this.action, required this.entry});

  const EntryNavigationResult.saved(this.entry)
    : action = EntryNavigationAction.saved;

  const EntryNavigationResult.deleted(this.entry)
    : action = EntryNavigationAction.deleted;
}
