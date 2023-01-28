import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/providers/queue_provider.dart';
import 'package:rythm/providers/settings_provider.dart';
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
  final tagger = Audiotagger();

  @override
  void initState() {
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

  ListTile MusicView(File fileEntity, {Uint8List? artwork}) {
    return ListTile(
      leading: artwork == null
          ? const FaIcon(FontAwesomeIcons.music)
          : Image.memory(
              artwork,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
      title: Text(fileEntity.path.split("/").last),
      onTap: () => playMusic(fileEntity.path, artwork),
    );
  }

  Stream<List<ListTile>> generateTiles() async* {
    List<ListTile> listViews = <ListTile>[];
    var settings = ref.read(settingsProvider);
    currentPath ??= settings!.localLibraryPath;
    if (currentPath != settings!.localLibraryPath) {
      listViews.add(ListTile(
        title: const Text("Back"),
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
    await for (var entity in dir.list(followLinks: false)) {
      if (entity is File) {
        var ext = entity.path.split("/").last.split(".").last;
        if (allowedExtensions.contains(ext)) {
          Uint8List? artwork = await tagger.readArtwork(path: entity.path);
          listViews.add(MusicView(entity, artwork: artwork));
        }
      } else if (entity is Directory &&
          !entity.path.split("/").last.startsWith(".")) {
        listViews.add(FolderView(entity));
      }
      yield listViews;
    }
  }

  playMusic(var path, Uint8List? artwork) async {
    AudioPlayer player = ref.read(playerProvider);

    var tags = await tagger.readTags(path: path);
    var songTitle = tags?.title != null && tags?.title != ""
        ? tags?.title
        : path?.split("/").last.split(".").first;

    Song song = Song()
      ..title = songTitle
      ..lyrics = tags?.lyrics
      ..filePath = path
      ..artwork = artwork;
    ref.read(queueProvider.notifier).setQueue([song]);

    // var artworkTempFolder = File("${(await getTemporaryDirectory()).path}");
    // if (await artworkTempFolder.exists()) {
    //   await artworkTempFolder.delete();
    // }
    // File? artworkTemp = artwork != null
    //     ? await File(
    //             "${artworkTempFolder.path}/${DateTime.now().microsecondsSinceEpoch}")
    //         .writeAsBytes(artwork, flush: true)
    //     : null;
    // player.setAudioSource(AudioSource.uri(
    //   Uri.file(path),
    //   tag: MediaItem(
    //     id: path,
    //     title: songTitle,
    //     artUri: artworkTemp?.uri,
    //   ),
    // ));

    await player.play();
  }

  // Navigate
  changeView({String? path}) {
    setState(() {
      currentPath = path;
    });
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

  @override
  Widget build(BuildContext context) {
    var settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: appBar(context),
      body: WillPopScope(
        onWillPop: () {
          if (currentPath != settings!.localLibraryPath) {
            Directory d = Directory(currentPath!);
            changeView(path: d.parent.path);
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: StreamBuilder<List<ListTile>>(
          stream: generateTiles(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                  return ListView.builder(
                    itemBuilder: (context, index) => snapshot.data![index],
                    itemCount: snapshot.data?.length ?? 0,
                  );
                case ConnectionState.done:
                  return ListView.builder(
                    itemBuilder: (context, index) => snapshot.data![index],
                    itemCount: snapshot.data?.length ?? 0,
                  );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          initialData: const [],
        ),
      ),
    );
  }
}
