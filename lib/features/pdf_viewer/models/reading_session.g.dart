// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingSessionAdapter extends TypeAdapter<ReadingSession> {
  @override
  final int typeId = 3;

  @override
  ReadingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingSession(
      id: fields[0] as String,
      pdfId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      startPage: fields[4] as int,
      endPage: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pdfId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.startPage)
      ..writeByte(5)
      ..write(obj.endPage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
