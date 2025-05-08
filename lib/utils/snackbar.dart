import 'package:flutter/material.dart';
import 'package:skin_diary/models/skin_entry.dart';

SnackBar buildUndoDeleteSnackBar({
  required SkinEntry entry,
  required Future<void> Function() onUndo,
}) {
  return SnackBar(
    content: const Text('Entry deleted'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        onUndo();
      },
    ),
  );
}
