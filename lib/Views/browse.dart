import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/providers/local_folder_provider.dart';
import 'package:rythm/providers/player_provider.dart';

class Browse extends ConsumerStatefulWidget {
  const Browse({
    Key? key,
  }) : super(key: key);
  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends ConsumerState<Browse> {
  String? currentPath;
  var listView = [];
  var loaded = false;
  final tagger = Audiotagger();
  @override
  void initState() {
    generateView();
    super.initState();
  }

  ListTile FolderView(Directory folderEntity) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folderEntity.path.split("/").last),
      onTap: () {
        changeView(path: folderEntity.path);
      },
    );
  }

  readArtwork(var filePath) async {}

  ListTile MusicView(File fileEntity, {Uint8List? artwork}) {
    return ListTile(
      leading: artwork == null
          ? const FaIcon(FontAwesomeIcons.music)
          : Image.memory(
              artwork,
              width: 126,
              height: 126,
            ),
      title: Text(fileEntity.path.split("/").last),
      onTap: () => playMusic(fileEntity.path),
    );
  }

  playMusic(var path) async {
    AudioPlayer player = ref.read(playerProvider);
    Uint8List? artwork = await tagger.readArtwork(path: path);
    //  var test= await tagger.readAudioFile(path: path);
    //  test.
    ref.read(songProvider.notifier).setSong(Song()
      ..filePath = path
      ..artwork = artwork);
    await player.setFilePath(path);

    player.play();
  }

  // Navigate
  changeView({String? path}) {
    setState(() {
      currentPath = path;
      listView.clear();
    });

    generateView();
  }

  generateView() async {
    var localFolderPath = ref.read(localFolderProvider);
    currentPath ??= localFolderPath;
    if (currentPath != localFolderPath) {
      listView.add(ListTile(
        title: const Text("../"),
        leading: const Icon(Icons.subdirectory_arrow_left_sharp),
        onTap: () {
          Directory d = Directory(currentPath!);
          changeView(path: d.parent.path);
        },
      ));
    }
    Directory dir = Directory(currentPath!);
    var allowedExtensions = ["mp3"];

    // Use a Streambuilder for this
    await for (var entity in dir.list()) {
      if (entity is File) {
        var ext = entity.path.split("/").last.split(".").last;
        if (allowedExtensions.contains(ext)) {
          listView.add(MusicView(
            entity,
          ));
        }
      } else if (entity is Directory &&
          !entity.path.split("/").last.startsWith(".")) {
        listView.add(FolderView(entity));
      }
    }
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var localFolderPath = ref.watch(localFolderProvider);
    return Scaffold(
      appBar: appBar(context),
      body: WillPopScope(
        onWillPop: () {
          if (currentPath != localFolderPath) {
            Directory d = Directory(currentPath!);
            changeView(path: d.parent.path);
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: loaded
            ? ListView.builder(
                itemCount: listView.length,
                itemBuilder: (context, index) => listView[index],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text("Browse Local"),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            changeView(path: currentPath);
          },
          icon: const FaIcon(
            FontAwesomeIcons.arrowsRotate,
            size: 20,
          ),
        )
      ],
    );
  }
}
