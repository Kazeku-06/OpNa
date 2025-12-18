import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool isPinned;

  @HiveField(5)
  String? folder;

  @HiveField(6)
  int currentVersion;

  @HiveField(7)
  int nextVersionNumber;

  @HiveField(8)
  bool isArchived;

  @HiveField(9)
  bool isDeleted;

  @HiveField(10)
  int sortOrder;

  Note({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.folder,
    this.currentVersion = 1,
    this.nextVersionNumber = 2,
    this.isArchived = false,
    this.isDeleted = false,
    this.sortOrder = 0,
  });

  Note copyWith({
    String? title,
    DateTime? updatedAt,
    bool? isPinned,
    String? folder,
    int? currentVersion,
    int? nextVersionNumber,
    bool? isArchived,
    bool? isDeleted,
    int? sortOrder,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      folder: folder ?? this.folder,
      currentVersion: currentVersion ?? this.currentVersion,
      nextVersionNumber: nextVersionNumber ?? this.nextVersionNumber,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, isPinned: $isPinned, folder: $folder, currentVersion: $currentVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
