import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Data/Settings.dart';
import 'package:rythm/Data/database.dart';
import 'package:rythm/Views/permission_request.dart';
import 'package:rythm/main_view.dart';
import 'package:rythm/providers/playlist_provider.dart';
import 'package:rythm/providers/settings_provider.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await getIsar();
  // ignore: prefer_const_constructors
  runApp(ProviderScope(child: Rythm()));
}

class Rythm extends ConsumerStatefulWidget {
  const Rythm({Key? key}) : super(key: key);

  @override
  _RythmState createState() => _RythmState();
}

class _RythmState extends ConsumerState<Rythm> {
  bool testingPerms = true;

  @override
  void initState() {
    runPrecheck();
    super.initState();
  }

  runPrecheck() async {
    var settings = await isarDB.settings.get(0);
    var playlists = await isarDB.playlists.where().findAll();

    String? localLibrayPath = settings?.localLibraryPath;

    if (localLibrayPath != null) {
      ref.read(settingsProvider.notifier).setSettings(settings!);
    }
    ref.read(playlistsProvider.notifier).setPlaylists(playlists);

    setState(() {
      testingPerms = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var settings = ref.watch(settingsProvider);
    return MaterialApp(
        darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.dellGenoa,
            useMaterial3: settings?.useMaterial3 ?? true),
        theme: FlexThemeData.light(
            scheme: FlexScheme.dellGenoa,
            useMaterial3: settings?.useMaterial3 ?? true),
        themeMode: themeModeToEnum(settings?.themeMode ?? ""),
        home: testingPerms
            ? const Center(child: CircularProgressIndicator())
            : settings!.localLibraryPath != null
                ? const MainView()
                : const PermissionRequest());
  }
}
