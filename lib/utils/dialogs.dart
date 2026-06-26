import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(confirmText),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> showDeleteEntryConfirmationDialog(BuildContext context) {
  return showConfirmDialog(
    context,
    title: 'Delete Entry',
    content: 'Are you sure you want to delete this entry?',
    confirmText: 'Delete',
    isDestructive: true,
  );
}

Future<bool> showDeleteProductConfirmationDialog(
  BuildContext context,
  String productName,
) {
  return showConfirmDialog(
    context,
    title: 'Delete Product',
    content: 'Are you sure you want to delete "$productName"?',
    confirmText: 'Delete',
    isDestructive: true,
  );
}

Future<bool> showArchiveProductConfirmationDialog(
  BuildContext context,
  String productName,
) {
  return showConfirmDialog(
    context,
    title: 'Archive Product',
    content: 'Move "$productName" to product history?',
    confirmText: 'Archive',
  );
}