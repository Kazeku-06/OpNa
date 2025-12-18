// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteTemplateAdapter extends TypeAdapter<NoteTemplate> {
  @override
  final int typeId = 1;

  @override
  NoteTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      isBuiltIn: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteTemplate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isBuiltIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
