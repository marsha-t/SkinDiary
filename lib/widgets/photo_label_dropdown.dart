import 'package:flutter/material.dart';

class PhotoLabelDropdown extends StatefulWidget {
  final void Function(String) onLabelSelected;

  const PhotoLabelDropdown({super.key, required this.onLabelSelected});

  @override
  State<PhotoLabelDropdown> createState() => _PhotoLabelDropdownState();
}

class _PhotoLabelDropdownState extends State<PhotoLabelDropdown> {
  final List<String> _predefinedLabels = [
    'Full Face',
    'Forehead',
    'Nose',
    'Left Cheek',
    'Right Cheek',
    'Chin',
    'Other (Custom)',
  ];
  
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _selectedLabel = _predefinedLabels.first;
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
          items: _predefinedLabels.map((label) {
            return DropdownMenuItem<String> (
              value: label, 
              child: Text(label),
            );
          }).toList(), 
          onChanged: (value) {
            setState(() {
              _selectedLabel = value;
              if (value != 'Other (Custom)') {
                widget.onLabelSelected(value!);
              }
            });
          },
        ),
        if (_selectedLabel == 'Other (Custom)')...[
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
        ]
      ],
    );
  }
}