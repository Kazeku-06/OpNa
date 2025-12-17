class NoteVersion {
  final String noteId;
  final int version;
  final DateTime createdAt;
  final String content;

  const NoteVersion({
    required this.noteId,
    required this.version,
    required this.createdAt,
    required this.content,
  });

  NoteVersion copyWith({
    String? noteId,
    int? version,
    DateTime? createdAt,
    String? content,
  }) {
    return NoteVersion(
      noteId: noteId ?? this.noteId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'NoteVersion(noteId: $noteId, version: $version, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteVersion &&
        other.noteId == noteId &&
        other.version == version;
  }

  @override
  int get hashCode => noteId.hashCode ^ version.hashCode;
}