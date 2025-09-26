// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingPreferencesAdapter extends TypeAdapter<ReadingPreferences> {
  @override
  final int typeId = 7;

  @override
  ReadingPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingPreferences(
      theme: fields[0] as ReadingTheme,
      brightness: fields[1] as double,
      fontSize: fields[2] as double,
      autoHideControls: fields[3] as bool,
      autoHideDelay: fields[4] as Duration,
      enablePageTransitions: fields[5] as bool,
      transitionType: fields[6] as PageTransitionType,
      enableNightMode: fields[7] as bool,
      customBackgroundColor: fields[8] as int,
      customTextColor: fields[9] as int,
      enableSepia: fields[10] as bool,
      sepiaIntensity: fields[11] as double,
      enableHighContrast: fields[12] as bool,
      zoomLevel: fields[13] as double,
      enableDoubleTapZoom: fields[14] as bool,
      enablePinchZoom: fields[15] as bool,
      enableSwipeNavigation: fields[16] as bool,
      swipeSensitivity: fields[17] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingPreferences obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.brightness)
      ..writeByte(2)
      ..write(obj.fontSize)
      ..writeByte(3)
      ..write(obj.autoHideControls)
      ..writeByte(4)
      ..write(obj.autoHideDelay)
      ..writeByte(5)
      ..write(obj.enablePageTransitions)
      ..writeByte(6)
      ..write(obj.transitionType)
      ..writeByte(7)
      ..write(obj.enableNightMode)
      ..writeByte(8)
      ..write(obj.customBackgroundColor)
      ..writeByte(9)
      ..write(obj.customTextColor)
      ..writeByte(10)
      ..write(obj.enableSepia)
      ..writeByte(11)
      ..write(obj.sepiaIntensity)
      ..writeByte(12)
      ..write(obj.enableHighContrast)
      ..writeByte(13)
      ..write(obj.zoomLevel)
      ..writeByte(14)
      ..write(obj.enableDoubleTapZoom)
      ..writeByte(15)
      ..write(obj.enablePinchZoom)
      ..writeByte(16)
      ..write(obj.enableSwipeNavigation)
      ..writeByte(17)
      ..write(obj.swipeSensitivity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingThemeAdapter extends TypeAdapter<ReadingTheme> {
  @override
  final int typeId = 5;

  @override
  ReadingTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReadingTheme.light;
      case 1:
        return ReadingTheme.dark;
      case 2:
        return ReadingTheme.sepia;
      case 3:
        return ReadingTheme.highContrast;
      case 4:
        return ReadingTheme.custom;
      default:
        return ReadingTheme.light;
    }
  }

  @override
  void write(BinaryWriter writer, ReadingTheme obj) {
    switch (obj) {
      case ReadingTheme.light:
        writer.writeByte(0);
        break;
      case ReadingTheme.dark:
        writer.writeByte(1);
        break;
      case ReadingTheme.sepia:
        writer.writeByte(2);
        break;
      case ReadingTheme.highContrast:
        writer.writeByte(3);
        break;
      case ReadingTheme.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PageTransitionTypeAdapter extends TypeAdapter<PageTransitionType> {
  @override
  final int typeId = 6;

  @override
  PageTransitionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PageTransitionType.slide;
      case 1:
        return PageTransitionType.fade;
      case 2:
        return PageTransitionType.scale;
      case 3:
        return PageTransitionType.none;
      default:
        return PageTransitionType.slide;
    }
  }

  @override
  void write(BinaryWriter writer, PageTransitionType obj) {
    switch (obj) {
      case PageTransitionType.slide:
        writer.writeByte(0);
        break;
      case PageTransitionType.fade:
        writer.writeByte(1);
        break;
      case PageTransitionType.scale:
        writer.writeByte(2);
        break;
      case PageTransitionType.none:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageTransitionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
