import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/providers/player_provider.dart';
import 'package:rythm/providers/playlist_provider.dart';

class PlaylistBrowse extends ConsumerStatefulWidget {
  PlaylistBrowse(
    this.playlists, {
    Key? key,
  }) : super(key: key);

  Playlist? playlists;

  @override
  _PlaylistBrowseState createState() => _PlaylistBrowseState();
}

class _PlaylistBrowseState extends ConsumerState<PlaylistBrowse> {
  Playlist? currentPlaylist;
  final tagger = Audiotagger();

  @override
  void initState() {
    super.initState();
  }

  ListTile PlaylistView(Playlist playlist) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.recordVinyl),
      title: Text(playlist.name ?? ""),
      subtitle: Text("${playlist.songs.length} songs"),
      onTap: () {
        changeView(playlist: playlist);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Playlist actions"),
              content: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text("Delete playlist (Hold to confirm)"),
                    leading: FaIcon(FontAwesomeIcons.trash),
                    iconColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).colorScheme.error,
                    onLongPress: () {
                      removePlaylistAction(playlist);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  removePlaylistAction(Playlist playlist) async {
    ref.read(playlistsProvider.notifier).removePlaylist(playlist.id);
  }

  ListTile MusicView(Song song) {
    return ListTile(
      leading: song.artwork == null
          ? const FaIcon(FontAwesomeIcons.music)
          : Image.memory(
              song.artwork as Uint8List,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
      title: Text(song.title ?? ""),
      onTap: () => playMusic(song),
    );
  }

  Stream<List<ListTile>> generateTiles() async* {
    List<ListTile> listViews = <ListTile>[];
    var playlists = ref.read(playlistsProvider);
    if (currentPlaylist != null) {
      listViews.add(ListTile(
        title: const Text("Back"),
        leading: const Icon(Icons.subdirectory_arrow_left_sharp),
        onTap: () {
          changeView();
        },
      ));
      for (Song song in currentPlaylist!.songs) {
        Uint8List? artwork = await tagger.readArtwork(path: song.filePath!);
        listViews.add(MusicView(song..artwork = artwork));
      }
      yield listViews;
    } else {
      for (Playlist playlist in playlists) {
        listViews.add(PlaylistView(playlist));
      }
      yield listViews;
    }
  }

  playMusic(Song song) async {
    AudioPlayer player = ref.read(playerProvider);
    var artworkTempFolder = File("${(await getTemporaryDirectory()).path}");
    if (await artworkTempFolder.exists()) {
      await artworkTempFolder.delete();
    }

    ref.read(songProvider.notifier).setSong(song);

    File? artworkTemp = song.artwork != null
        ? await File(
                "${artworkTempFolder.path}/${DateTime.now().microsecondsSinceEpoch}")
            .writeAsBytes(song.artwork!, flush: true)
        : null;
    player.setAudioSource(AudioSource.uri(
      Uri.file(song.filePath!),
      tag: MediaItem(
        id: song.filePath!,
        title: song.title ?? "",
        artUri: artworkTemp?.uri,
      ),
    ));

    player.play();
  }

  // Navigate
  changeView({Playlist? playlist}) {
    setState(() {
      currentPlaylist = playlist;
    });
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text("Playlists"),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            changeView(playlist: currentPlaylist);
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
    var playlists = ref.watch(playlistsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlaylist?.name ?? "Playlists"),
        actions: currentPlaylist == null
            ? [
                IconButton(
                    onPressed: () {
                      showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          String val = "";
                          return AlertDialog(
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Playlist playlist = Playlist()..name = val;
                                    ref
                                        .read(playlistsProvider.notifier)
                                        .addPlaylist(playlist);

                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Create")),
                            ],
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            contentPadding: EdgeInsets.all(16.0),
                            title: const Text("Create Playlist"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  onChanged: (value) {
                                    val = value;
                                  },
                                  decoration: InputDecoration(
                                      label: Text("Playlist name")),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: FaIcon(FontAwesomeIcons.plus))
              ]
            : null,
      ),
      body: WillPopScope(
        onWillPop: () {
          if (currentPlaylist != null) {
            changeView(playlist: null);
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
          initialData: [],
        ),
      ),
    );
  }
}
