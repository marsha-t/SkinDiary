import 'package:flutter/material.dart';
import 'package:skin_diary/constants/photo_labels.dart';

class PhotoLabelDropdown extends StatefulWidget {
  final void Function(String) onLabelSelected;

  const PhotoLabelDropdown({super.key, required this.onLabelSelected});

  @override
  State<PhotoLabelDropdown> createState() => _PhotoLabelDropdownState();
}

class _PhotoLabelDropdownState extends State<PhotoLabelDropdown> {
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _selectedLabel = photoLabels.first;
    widget.onLabelSelected(_selectedLabel!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select photo label:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          value: _selectedLabel,
          items:
              photoLabels.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLabel = value;
              if (value != customPhotoLabelOption) {
                widget.onLabelSelected(value!);
              }
            });
          },
        ),
        if (_selectedLabel == customPhotoLabelOption) ...[
          const SizedBox(height: 12),
          const Text('Enter custom label:'),
          TextField(
            onChanged: (value) {
              widget.onLabelSelected(value);
            },
            decoration: const InputDecoration(
              hintText: 'e.g., Left Temple',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
