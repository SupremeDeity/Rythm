import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rythm/Data/Settings.dart';
import 'package:rythm/Data/database.dart';
import 'package:rythm/providers/settings_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    var settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(children: [
        ListTile(
          title: const Text("Theme"),
          trailing: DropdownButton<String>(
            value: FlexScheme.values
                .byName(settings?.currentTheme ?? FlexScheme.dellGenoa.name)
                .name,
            items: FlexScheme.values
                .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                      value: e.name,
                      child: Text(e.toString().dotTail.capitalize),
                    ))
                .toList(),
            onChanged: (value) {
              if (settings != null) {
                isarDB.writeTxnSync(() {
                  isarDB.settings
                      .putSync(settings.copyWith(newCurrentTheme: value));
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text("Theme Mode"),
          trailing: DropdownButton<String>(
            value: settings?.themeMode ?? "",
            items: ThemeMode.values
                .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                      value: e.toString(),
                      child: Text(e.toString().dotTail),
                    ))
                .toList(),
            onChanged: (value) {
              if (settings != null) {
                isarDB.writeTxnSync(() {
                  isarDB.settings
                      .putSync(settings.copyWith(newThemeMode: value));
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text("Use Material 3"),
          trailing: Switch(
            thumbIcon: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Icon(
                  Icons.done_rounded,
                  color: Theme.of(context).colorScheme.background,
                );
              }

              return const Icon(Icons.close_rounded);
            }),
            value: settings?.useMaterial3 ?? true,
            onChanged: (value) {
              if (settings != null) {
                isarDB.writeTxnSync(() {
                  isarDB.settings
                      .putSync(settings.copyWith(newUseMaterial3: value));
                });
              }
            },
          ),
        )
      ]),
    );
  }
}
