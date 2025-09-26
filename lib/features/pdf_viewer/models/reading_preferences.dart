import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'reading_preferences.g.dart';

@HiveType(typeId: 5)
enum ReadingTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  sepia,
  @HiveField(3)
  highContrast,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 6)
enum PageTransitionType {
  @HiveField(0)
  slide,
  @HiveField(1)
  fade,
  @HiveField(2)
  scale,
  @HiveField(3)
  none,
}

@HiveType(typeId: 7)
class ReadingPreferences extends Equatable {
  const ReadingPreferences({
    this.theme = ReadingTheme.light,
    this.brightness = 1.0,
    this.fontSize = 16.0,
    this.autoHideControls = true,
    this.autoHideDelay = const Duration(seconds: 3),
    this.enablePageTransitions = true,
    this.transitionType = PageTransitionType.slide,
    this.enableNightMode = false,
    this.customBackgroundColor = 0xFFFFFFFF,
    this.customTextColor = 0xFF000000,
    this.enableSepia = false,
    this.sepiaIntensity = 0.3,
    this.enableHighContrast = false,
    this.zoomLevel = 1.0,
    this.enableDoubleTapZoom = true,
    this.enablePinchZoom = true,
    this.enableSwipeNavigation = true,
    this.swipeSensitivity = 0.5,
  });

  @HiveField(0)
  final ReadingTheme theme;

  @HiveField(1)
  final double brightness;

  @HiveField(2)
  final double fontSize;

  @HiveField(3)
  final bool autoHideControls;

  @HiveField(4)
  final Duration autoHideDelay;

  @HiveField(5)
  final bool enablePageTransitions;

  @HiveField(6)
  final PageTransitionType transitionType;

  @HiveField(7)
  final bool enableNightMode;

  @HiveField(8)
  final int customBackgroundColor;

  @HiveField(9)
  final int customTextColor;

  @HiveField(10)
  final bool enableSepia;

  @HiveField(11)
  final double sepiaIntensity;

  @HiveField(12)
  final bool enableHighContrast;

  @HiveField(13)
  final double zoomLevel;

  @HiveField(14)
  final bool enableDoubleTapZoom;

  @HiveField(15)
  final bool enablePinchZoom;

  @HiveField(16)
  final bool enableSwipeNavigation;

  @HiveField(17)
  final double swipeSensitivity;

  // Factory constructor for creating from JSON
  factory ReadingPreferences.fromJson(Map<String, dynamic> json) {
    return ReadingPreferences(
      theme: ReadingTheme.values.firstWhere(
        (e) => e.toString() == 'ReadingTheme.${json['theme']}',
        orElse: () => ReadingTheme.light,
      ),
      brightness: (json['brightness'] as num?)?.toDouble() ?? 1.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      autoHideControls: json['autoHideControls'] as bool? ?? true,
      autoHideDelay: Duration(
        seconds: json['autoHideDelaySeconds'] as int? ?? 3,
      ),
      enablePageTransitions: json['enablePageTransitions'] as bool? ?? true,
      transitionType: PageTransitionType.values.firstWhere(
        (e) => e.toString() == 'PageTransitionType.${json['transitionType']}',
        orElse: () => PageTransitionType.slide,
      ),
      enableNightMode: json['enableNightMode'] as bool? ?? false,
      customBackgroundColor:
          json['customBackgroundColor'] as int? ?? 0xFFFFFFFF,
      customTextColor: json['customTextColor'] as int? ?? 0xFF000000,
      enableSepia: json['enableSepia'] as bool? ?? false,
      sepiaIntensity: (json['sepiaIntensity'] as num?)?.toDouble() ?? 0.3,
      enableHighContrast: json['enableHighContrast'] as bool? ?? false,
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble() ?? 1.0,
      enableDoubleTapZoom: json['enableDoubleTapZoom'] as bool? ?? true,
      enablePinchZoom: json['enablePinchZoom'] as bool? ?? true,
      enableSwipeNavigation: json['enableSwipeNavigation'] as bool? ?? true,
      swipeSensitivity: (json['swipeSensitivity'] as num?)?.toDouble() ?? 0.5,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'theme': theme.toString().split('.').last,
      'brightness': brightness,
      'fontSize': fontSize,
      'autoHideControls': autoHideControls,
      'autoHideDelaySeconds': autoHideDelay.inSeconds,
      'enablePageTransitions': enablePageTransitions,
      'transitionType': transitionType.toString().split('.').last,
      'enableNightMode': enableNightMode,
      'customBackgroundColor': customBackgroundColor,
      'customTextColor': customTextColor,
      'enableSepia': enableSepia,
      'sepiaIntensity': sepiaIntensity,
      'enableHighContrast': enableHighContrast,
      'zoomLevel': zoomLevel,
      'enableDoubleTapZoom': enableDoubleTapZoom,
      'enablePinchZoom': enablePinchZoom,
      'enableSwipeNavigation': enableSwipeNavigation,
      'swipeSensitivity': swipeSensitivity,
    };
  }

  // CopyWith method for immutability
  ReadingPreferences copyWith({
    ReadingTheme? theme,
    double? brightness,
    double? fontSize,
    bool? autoHideControls,
    Duration? autoHideDelay,
    bool? enablePageTransitions,
    PageTransitionType? transitionType,
    bool? enableNightMode,
    int? customBackgroundColor,
    int? customTextColor,
    bool? enableSepia,
    double? sepiaIntensity,
    bool? enableHighContrast,
    double? zoomLevel,
    bool? enableDoubleTapZoom,
    bool? enablePinchZoom,
    bool? enableSwipeNavigation,
    double? swipeSensitivity,
  }) {
    return ReadingPreferences(
      theme: theme ?? this.theme,
      brightness: brightness ?? this.brightness,
      fontSize: fontSize ?? this.fontSize,
      autoHideControls: autoHideControls ?? this.autoHideControls,
      autoHideDelay: autoHideDelay ?? this.autoHideDelay,
      enablePageTransitions:
          enablePageTransitions ?? this.enablePageTransitions,
      transitionType: transitionType ?? this.transitionType,
      enableNightMode: enableNightMode ?? this.enableNightMode,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      customTextColor: customTextColor ?? this.customTextColor,
      enableSepia: enableSepia ?? this.enableSepia,
      sepiaIntensity: sepiaIntensity ?? this.sepiaIntensity,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      enablePinchZoom: enablePinchZoom ?? this.enablePinchZoom,
      enableSwipeNavigation:
          enableSwipeNavigation ?? this.enableSwipeNavigation,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
    );
  }

  // Computed properties
  bool get isDarkTheme => theme == ReadingTheme.dark || enableNightMode;

  bool get isCustomTheme => theme == ReadingTheme.custom;

  bool get hasCustomColors =>
      customBackgroundColor != 0xFFFFFFFF || customTextColor != 0xFF000000;

  String get themeDisplayName {
    switch (theme) {
      case ReadingTheme.light:
        return 'Light';
      case ReadingTheme.dark:
        return 'Dark';
      case ReadingTheme.sepia:
        return 'Sepia';
      case ReadingTheme.highContrast:
        return 'High Contrast';
      case ReadingTheme.custom:
        return 'Custom';
    }
  }

  String get transitionDisplayName {
    switch (transitionType) {
      case PageTransitionType.slide:
        return 'Slide';
      case PageTransitionType.fade:
        return 'Fade';
      case PageTransitionType.scale:
        return 'Scale';
      case PageTransitionType.none:
        return 'None';
    }
  }

  // Validation methods
  bool get isValid {
    return brightness >= 0.1 &&
        brightness <= 1.0 &&
        fontSize >= 8.0 &&
        fontSize <= 32.0 &&
        sepiaIntensity >= 0.0 &&
        sepiaIntensity <= 1.0 &&
        zoomLevel >= 0.5 &&
        zoomLevel <= 5.0 &&
        swipeSensitivity >= 0.1 &&
        swipeSensitivity <= 1.0;
  }

  // Preset configurations
  static const ReadingPreferences lightPreset = ReadingPreferences(
    theme: ReadingTheme.light,
    brightness: 1.0,
    enableNightMode: false,
  );

  static const ReadingPreferences darkPreset = ReadingPreferences(
    theme: ReadingTheme.dark,
    brightness: 0.8,
    enableNightMode: true,
  );

  static const ReadingPreferences sepiaPreset = ReadingPreferences(
    theme: ReadingTheme.sepia,
    brightness: 0.9,
    enableSepia: true,
    sepiaIntensity: 0.3,
  );

  static const ReadingPreferences highContrastPreset = ReadingPreferences(
    theme: ReadingTheme.highContrast,
    brightness: 1.0,
    enableHighContrast: true,
    fontSize: 18.0,
  );

  @override
  List<Object?> get props => [
    theme,
    brightness,
    fontSize,
    autoHideControls,
    autoHideDelay,
    enablePageTransitions,
    transitionType,
    enableNightMode,
    customBackgroundColor,
    customTextColor,
    enableSepia,
    sepiaIntensity,
    enableHighContrast,
    zoomLevel,
    enableDoubleTapZoom,
    enablePinchZoom,
    enableSwipeNavigation,
    swipeSensitivity,
  ];

  @override
  String toString() =>
      'ReadingPreferences(theme: $themeDisplayName, brightness: $brightness)';
}
