import 'package:hive/hive.dart';

part 'note_template.g.dart';

@HiveType(typeId: 1)
class NoteTemplate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  bool isBuiltIn;

  NoteTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isBuiltIn = false,
  });

  NoteTemplate copyWith({
    String? name,
    String? content,
    DateTime? updatedAt,
    bool? isBuiltIn,
  }) {
    return NoteTemplate(
      id: id,
      name: name ?? this.name,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}
