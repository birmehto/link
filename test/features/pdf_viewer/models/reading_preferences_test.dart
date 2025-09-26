import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/pdf_viewer/models/models.dart';

void main() {
  group('ReadingPreferences Model Tests', () {
    late ReadingPreferences testPreferences;

    setUp(() {
      testPreferences = const ReadingPreferences(
        theme: ReadingTheme.sepia,
        brightness: 0.8,
        fontSize: 18.0,
        autoHideControls: true,
        autoHideDelay: Duration(seconds: 5),
        enablePageTransitions: true,
        transitionType: PageTransitionType.fade,
        enableNightMode: false,
        customBackgroundColor: 0xFFF5F5DC,
        customTextColor: 0xFF333333,
        enableSepia: true,
        sepiaIntensity: 0.4,
        enableHighContrast: false,
        zoomLevel: 1.2,
        enableDoubleTapZoom: true,
        enablePinchZoom: true,
        enableSwipeNavigation: true,
        swipeSensitivity: 0.7,
      );
    });

    test('should create ReadingPreferences with all properties', () {
      expect(testPreferences.theme, ReadingTheme.sepia);
      expect(testPreferences.brightness, 0.8);
      expect(testPreferences.fontSize, 18.0);
      expect(testPreferences.autoHideControls, true);
      expect(testPreferences.autoHideDelay, const Duration(seconds: 5));
      expect(testPreferences.enablePageTransitions, true);
      expect(testPreferences.transitionType, PageTransitionType.fade);
      expect(testPreferences.enableNightMode, false);
      expect(testPreferences.customBackgroundColor, 0xFFF5F5DC);
      expect(testPreferences.customTextColor, 0xFF333333);
      expect(testPreferences.enableSepia, true);
      expect(testPreferences.sepiaIntensity, 0.4);
      expect(testPreferences.enableHighContrast, false);
      expect(testPreferences.zoomLevel, 1.2);
      expect(testPreferences.enableDoubleTapZoom, true);
      expect(testPreferences.enablePinchZoom, true);
      expect(testPreferences.enableSwipeNavigation, true);
      expect(testPreferences.swipeSensitivity, 0.7);
    });

    test('should create with default values', () {
      const defaultPrefs = ReadingPreferences();

      expect(defaultPrefs.theme, ReadingTheme.light);
      expect(defaultPrefs.brightness, 1.0);
      expect(defaultPrefs.fontSize, 16.0);
      expect(defaultPrefs.autoHideControls, true);
      expect(defaultPrefs.autoHideDelay, const Duration(seconds: 3));
      expect(defaultPrefs.enablePageTransitions, true);
      expect(defaultPrefs.transitionType, PageTransitionType.slide);
      expect(defaultPrefs.enableNightMode, false);
      expect(defaultPrefs.zoomLevel, 1.0);
      expect(defaultPrefs.swipeSensitivity, 0.5);
    });

    test('should serialize to JSON correctly', () {
      final json = testPreferences.toJson();

      expect(json['theme'], 'sepia');
      expect(json['brightness'], 0.8);
      expect(json['fontSize'], 18.0);
      expect(json['autoHideControls'], true);
      expect(json['autoHideDelaySeconds'], 5);
      expect(json['enablePageTransitions'], true);
      expect(json['transitionType'], 'fade');
      expect(json['enableNightMode'], false);
      expect(json['customBackgroundColor'], 0xFFF5F5DC);
      expect(json['customTextColor'], 0xFF333333);
      expect(json['enableSepia'], true);
      expect(json['sepiaIntensity'], 0.4);
      expect(json['enableHighContrast'], false);
      expect(json['zoomLevel'], 1.2);
      expect(json['enableDoubleTapZoom'], true);
      expect(json['enablePinchZoom'], true);
      expect(json['enableSwipeNavigation'], true);
      expect(json['swipeSensitivity'], 0.7);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'theme': 'dark',
        'brightness': 0.6,
        'fontSize': 20.0,
        'autoHideControls': false,
        'autoHideDelaySeconds': 10,
        'enablePageTransitions': false,
        'transitionType': 'scale',
        'enableNightMode': true,
        'customBackgroundColor': 0xFF000000,
        'customTextColor': 0xFFFFFFFF,
        'enableSepia': false,
        'sepiaIntensity': 0.2,
        'enableHighContrast': true,
        'zoomLevel': 1.5,
        'enableDoubleTapZoom': false,
        'enablePinchZoom': false,
        'enableSwipeNavigation': false,
        'swipeSensitivity': 0.3,
      };

      final preferences = ReadingPreferences.fromJson(json);

      expect(preferences.theme, ReadingTheme.dark);
      expect(preferences.brightness, 0.6);
      expect(preferences.fontSize, 20.0);
      expect(preferences.autoHideControls, false);
      expect(preferences.autoHideDelay, const Duration(seconds: 10));
      expect(preferences.enablePageTransitions, false);
      expect(preferences.transitionType, PageTransitionType.scale);
      expect(preferences.enableNightMode, true);
      expect(preferences.customBackgroundColor, 0xFF000000);
      expect(preferences.customTextColor, 0xFFFFFFFF);
      expect(preferences.enableSepia, false);
      expect(preferences.sepiaIntensity, 0.2);
      expect(preferences.enableHighContrast, true);
      expect(preferences.zoomLevel, 1.5);
      expect(preferences.enableDoubleTapZoom, false);
      expect(preferences.enablePinchZoom, false);
      expect(preferences.enableSwipeNavigation, false);
      expect(preferences.swipeSensitivity, 0.3);
    });

    test('should handle invalid JSON values with defaults', () {
      final json = {
        'theme': 'invalid_theme',
        'transitionType': 'invalid_transition',
      };

      final preferences = ReadingPreferences.fromJson(json);

      expect(preferences.theme, ReadingTheme.light);
      expect(preferences.transitionType, PageTransitionType.slide);
      expect(preferences.brightness, 1.0);
      expect(preferences.fontSize, 16.0);
    });

    test('should create copy with modified properties', () {
      final modifiedPreferences = testPreferences.copyWith(
        theme: ReadingTheme.dark,
        brightness: 0.5,
        fontSize: 20.0,
        enableNightMode: true,
      );

      expect(modifiedPreferences.theme, ReadingTheme.dark);
      expect(modifiedPreferences.brightness, 0.5);
      expect(modifiedPreferences.fontSize, 20.0);
      expect(modifiedPreferences.enableNightMode, true);
      // Other properties should remain the same
      expect(
        modifiedPreferences.autoHideControls,
        testPreferences.autoHideControls,
      );
      expect(modifiedPreferences.zoomLevel, testPreferences.zoomLevel);
    });

    test('should validate computed properties correctly', () {
      expect(testPreferences.isDarkTheme, false);
      expect(testPreferences.isCustomTheme, false);
      expect(testPreferences.hasCustomColors, true);
      expect(testPreferences.themeDisplayName, 'Sepia');
      expect(testPreferences.transitionDisplayName, 'Fade');

      final darkPrefs = testPreferences.copyWith(theme: ReadingTheme.dark);
      expect(darkPrefs.isDarkTheme, true);

      final nightModePrefs = testPreferences.copyWith(enableNightMode: true);
      expect(nightModePrefs.isDarkTheme, true);

      final customPrefs = testPreferences.copyWith(theme: ReadingTheme.custom);
      expect(customPrefs.isCustomTheme, true);

      final defaultColorPrefs = testPreferences.copyWith(
        customBackgroundColor: 0xFFFFFFFF,
        customTextColor: 0xFF000000,
      );
      expect(defaultColorPrefs.hasCustomColors, false);
    });

    test('should validate all theme display names', () {
      expect(
        testPreferences.copyWith(theme: ReadingTheme.light).themeDisplayName,
        'Light',
      );
      expect(
        testPreferences.copyWith(theme: ReadingTheme.dark).themeDisplayName,
        'Dark',
      );
      expect(
        testPreferences.copyWith(theme: ReadingTheme.sepia).themeDisplayName,
        'Sepia',
      );
      expect(
        testPreferences
            .copyWith(theme: ReadingTheme.highContrast)
            .themeDisplayName,
        'High Contrast',
      );
      expect(
        testPreferences.copyWith(theme: ReadingTheme.custom).themeDisplayName,
        'Custom',
      );
    });

    test('should validate all transition display names', () {
      expect(
        testPreferences
            .copyWith(transitionType: PageTransitionType.slide)
            .transitionDisplayName,
        'Slide',
      );
      expect(
        testPreferences
            .copyWith(transitionType: PageTransitionType.fade)
            .transitionDisplayName,
        'Fade',
      );
      expect(
        testPreferences
            .copyWith(transitionType: PageTransitionType.scale)
            .transitionDisplayName,
        'Scale',
      );
      expect(
        testPreferences
            .copyWith(transitionType: PageTransitionType.none)
            .transitionDisplayName,
        'None',
      );
    });

    test('should validate preferences correctly', () {
      expect(testPreferences.isValid, true);

      // Invalid brightness
      final invalidBrightness = testPreferences.copyWith(brightness: 1.5);
      expect(invalidBrightness.isValid, false);

      // Invalid font size
      final invalidFontSize = testPreferences.copyWith(fontSize: 5.0);
      expect(invalidFontSize.isValid, false);

      // Invalid sepia intensity
      final invalidSepia = testPreferences.copyWith(sepiaIntensity: 1.5);
      expect(invalidSepia.isValid, false);

      // Invalid zoom level
      final invalidZoom = testPreferences.copyWith(zoomLevel: 6.0);
      expect(invalidZoom.isValid, false);

      // Invalid swipe sensitivity
      final invalidSwipe = testPreferences.copyWith(swipeSensitivity: 1.5);
      expect(invalidSwipe.isValid, false);
    });

    test('should provide correct preset configurations', () {
      expect(ReadingPreferences.lightPreset.theme, ReadingTheme.light);
      expect(ReadingPreferences.lightPreset.brightness, 1.0);
      expect(ReadingPreferences.lightPreset.enableNightMode, false);

      expect(ReadingPreferences.darkPreset.theme, ReadingTheme.dark);
      expect(ReadingPreferences.darkPreset.brightness, 0.8);
      expect(ReadingPreferences.darkPreset.enableNightMode, true);

      expect(ReadingPreferences.sepiaPreset.theme, ReadingTheme.sepia);
      expect(ReadingPreferences.sepiaPreset.enableSepia, true);
      expect(ReadingPreferences.sepiaPreset.sepiaIntensity, 0.3);

      expect(
        ReadingPreferences.highContrastPreset.theme,
        ReadingTheme.highContrast,
      );
      expect(ReadingPreferences.highContrastPreset.enableHighContrast, true);
      expect(ReadingPreferences.highContrastPreset.fontSize, 18.0);
    });

    test('should implement equality correctly', () {
      final identicalPreferences = const ReadingPreferences(
        theme: ReadingTheme.sepia,
        brightness: 0.8,
        fontSize: 18.0,
        autoHideControls: true,
        autoHideDelay: Duration(seconds: 5),
        enablePageTransitions: true,
        transitionType: PageTransitionType.fade,
        enableNightMode: false,
        customBackgroundColor: 0xFFF5F5DC,
        customTextColor: 0xFF333333,
        enableSepia: true,
        sepiaIntensity: 0.4,
        enableHighContrast: false,
        zoomLevel: 1.2,
        enableDoubleTapZoom: true,
        enablePinchZoom: true,
        enableSwipeNavigation: true,
        swipeSensitivity: 0.7,
      );

      final differentPreferences = testPreferences.copyWith(
        theme: ReadingTheme.dark,
      );

      expect(testPreferences, identicalPreferences);
      expect(testPreferences == differentPreferences, false);
      expect(testPreferences.hashCode, identicalPreferences.hashCode);
    });

    test('should have proper toString representation', () {
      expect(
        testPreferences.toString(),
        'ReadingPreferences(theme: Sepia, brightness: 0.8)',
      );
    });
  });
}
