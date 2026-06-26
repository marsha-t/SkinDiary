import 'package:flutter/material.dart';

SnackBar buildUndoSnackBar({
  required String message,
  required Future<void> Function() onUndo,
}) {
  return SnackBar(
    duration: const Duration(seconds: 4),
    content: Text(message),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        onUndo();
      },
    ),
  );
}
