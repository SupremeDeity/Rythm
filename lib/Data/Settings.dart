import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'Settings.g.dart';

@collection
class Settings {
  Id id = 0; // Only one record
  String? localLibraryPath;
  String themeMode = ThemeMode.system.toString();
  bool useMaterial3 = true;

  Settings copyWith(
      {String? newLibPath, String? newThemeMode, bool? newUseMaterial3}) {
    return Settings()
      ..localLibraryPath = newLibPath ?? localLibraryPath
      ..themeMode = newThemeMode ?? themeMode
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
