// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingStatsAdapter extends TypeAdapter<ReadingStats> {
  @override
  final int typeId = 4;

  @override
  ReadingStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingStats(
      pdfId: fields[0] as String,
      sessions: (fields[1] as List).cast<ReadingSession>(),
      dailyReadingTime: (fields[2] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingStats obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pdfId)
      ..writeByte(1)
      ..write(obj.sessions)
      ..writeByte(2)
      ..write(obj.dailyReadingTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
