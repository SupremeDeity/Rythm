import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Data/Settings.dart';

late Isar isarDB;

getIsar() async {
  var dir = await getApplicationSupportDirectory();
  isarDB = Isar.openSync(
    [PlaylistSchema, SettingsSchema],
    compactOnLaunch: const CompactCondition(minRatio: 2.0),
    inspector: !kReleaseMode,
    directory: dir.path,
  );
}
