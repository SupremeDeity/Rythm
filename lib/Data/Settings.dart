import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'Settings.g.dart';

@collection
class Settings {
  Id id = 0; // Only one record
  String? localLibraryPath;
  String themeMode = ThemeMode.system.toString();
  bool useMaterial3 = true;
  String currentTheme = FlexScheme.dellGenoa.name;

  Settings copyWith(
      {String? newLibPath,
      String? newThemeMode,
      bool? newUseMaterial3,
      String? newCurrentTheme}) {
    return Settings()
      ..localLibraryPath = newLibPath ?? localLibraryPath
      ..themeMode = newThemeMode ?? themeMode
      ..currentTheme = newCurrentTheme ?? currentTheme
      ..useMaterial3 = newUseMaterial3 ?? useMaterial3;
  }
}

// Helper functions
ThemeMode themeModeToEnum(String thememode) {
  for (ThemeMode mode in ThemeMode.values) {
    if (thememode == mode.toString()) {
      return mode;
    }
  }
  return ThemeMode.system; // Fallback
}
