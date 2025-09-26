import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Rect adapter for Hive
class RectAdapter extends TypeAdapter<Rect> {
  @override
  final int typeId = 10;

  @override
  Rect read(BinaryReader reader) {
    final left = reader.readDouble();
    final top = reader.readDouble();
    final right = reader.readDouble();
    final bottom = reader.readDouble();
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  void write(BinaryWriter writer, Rect obj) {
    writer.writeDouble(obj.left);
    writer.writeDouble(obj.top);
    writer.writeDouble(obj.right);
    writer.writeDouble(obj.bottom);
  }
}

// Color adapter for Hive
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 11;

  @override
  Color read(BinaryReader reader) {
    final value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}

// DateTime adapter for Hive (if not already registered)
class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 12;

  @override
  DateTime read(BinaryReader reader) {
    final millisecondsSinceEpoch = reader.readInt();
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
