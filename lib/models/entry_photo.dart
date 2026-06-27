class EntryPhoto {
  final String path;
  final String label;

  const EntryPhoto({required this.path, required this.label});

  Map<String, dynamic> toMap() {
    return {'path': path, 'label': label};
  }

  factory EntryPhoto.fromMap(Map<String, dynamic> map) {
    return EntryPhoto(
      path: map['path'] as String,
      label: map['label'] as String? ?? '',
    );
  }

  EntryPhoto copyWith({String? path, String? label}) {
    return EntryPhoto(path: path ?? this.path, label: label ?? this.label);
  }
}
