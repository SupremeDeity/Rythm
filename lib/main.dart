import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rythm/Views/permission_request.dart';
import 'package:rythm/main_view.dart';
import 'package:rythm/providers/local_folder_provider.dart';

Future<void> main() async {
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'supremedeity.rythm',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );
  await Hive.initFlutter();
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
  runPrecheck() async {
    var settingsBox = await Hive.openBox('settingsBox');
    String? localLibrayPath = settingsBox.get("localLibraryPath");

    if (localLibrayPath != null) {
      ref.read(localFolderProvider.notifier).set(localLibrayPath);
    }
    setState(() {
      testingPerms = false;
    });
  }

  @override
  void initState() {
    runPrecheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localFolderPath = ref.watch(localFolderProvider);
    return MaterialApp(
        darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.dellGenoa, useMaterial3: true),
        theme: FlexThemeData.light(
            scheme: FlexScheme.dellGenoa, useMaterial3: true),
        themeMode: ThemeMode.system,
        home: testingPerms
            ? const Center(child: CircularProgressIndicator())
            : localFolderPath != null
                ? MainView()
                : const PermissionRequest());
  }
}
