enum NoteStatus { active, archived, deleted }

class NoteState {
  final String id;
  final NoteStatus status;
  final int sortOrder;
  final DateTime statusChangedAt;

  const NoteState({
    required this.id,
    this.status = NoteStatus.active,
    this.sortOrder = 0,
    required this.statusChangedAt,
  });

  NoteState copyWith({
    String? id,
    NoteStatus? status,
    int? sortOrder,
    DateTime? statusChangedAt,
  }) {
    return NoteState(
      id: id ?? this.id,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
    );
  }
}
