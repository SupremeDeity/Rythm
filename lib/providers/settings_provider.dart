import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:rythm/Data/Settings.dart';
import 'package:rythm/Data/database.dart';

class SettingsNotififier extends Notifier<Settings?> {
  setSettings(Settings settings) {
    state = settings;
  }

  @override
  Settings? build() {
    isarDB.settings.watchLazy(fireImmediately: true).listen((event) {
      setSettings(isarDB.settings.getSync(0) ?? Settings());
    });
    return Settings();
  }
}

final settingsProvider = NotifierProvider<SettingsNotififier, Settings?>(() {
  return SettingsNotififier();
});
