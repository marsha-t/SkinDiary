import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false; // default to false if dialog is dismissed
}

// Future<bool> showConfirmDialog(
//   BuildContext context, {
//   required String title,
//   required String content,
//   String confirmText = 'Delete',
//   String cancelText = 'Cancel',
// }) async {
//   return await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(title),
//           content: Text(content),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(cancelText),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: Text(confirmText),
//             ),
//           ],
//         ),
//       ) ??
//       false;
// }
