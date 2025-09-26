// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HighlightAdapter extends TypeAdapter<Highlight> {
  @override
  final int typeId = 0;

  @override
  Highlight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Highlight(
      id: fields[0] as String,
      pdfId: fields[1] as String,
      pageNumber: fields[2] as int,
      selectedText: fields[3] as String,
      boundingBox: fields[4] as Rect,
      color: fields[5] as Color,
      createdAt: fields[6] as DateTime,
      noteId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Highlight obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pdfId)
      ..writeByte(2)
      ..write(obj.pageNumber)
      ..writeByte(3)
      ..write(obj.selectedText)
      ..writeByte(4)
      ..write(obj.boundingBox)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.noteId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
