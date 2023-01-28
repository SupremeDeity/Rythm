import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rythm/Data/database.dart';
import 'package:rythm/Data/Settings.dart';

class PermissionRequest extends ConsumerStatefulWidget {
  const PermissionRequest({Key? key}) : super(key: key);

  @override
  _PermissionRequestState createState() => _PermissionRequestState();
}

class _PermissionRequestState extends ConsumerState<PermissionRequest> {
  requestPerm() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      Settings newSettings = Settings()..localLibraryPath = selectedDirectory;
      await isarDB.writeTxn(() async {
        await isarDB.settings.put(newSettings);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder, size: 48),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Choose a folder to browse your local music.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          FilledButton(
              onPressed: () => requestPerm(),
              child: const Text("Select folder"))
        ],
      ),
    );
  }
}
