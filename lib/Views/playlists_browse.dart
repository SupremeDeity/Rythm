import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/providers/player_provider.dart';
import 'package:rythm/providers/playlist_provider.dart';
import 'package:rythm/providers/queue_provider.dart';

class PlaylistsBrowse extends ConsumerStatefulWidget {
  const PlaylistsBrowse({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlaylistsBrowseState();
}

class _PlaylistsBrowseState extends ConsumerState<PlaylistsBrowse> {
  int? currentPlaylistIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Playlist> playlists = ref.watch(playlistsProvider);

    return WillPopScope(
      onWillPop: () {
        if (currentPlaylistIndex != null) {
          setState(() {
            currentPlaylistIndex = null;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentPlaylistIndex != null
              ? playlists[currentPlaylistIndex!].name!
              : "Playlists"),
          actions: currentPlaylistIndex == null
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
                                      Playlist playlist = Playlist()
                                        ..name = val;
                                      ref
                                          .read(playlistsProvider.notifier)
                                          .addPlaylist(playlist);

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Create")),
                              ],
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              contentPadding: const EdgeInsets.all(16.0),
                              title: const Text("Create Playlist"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      val = value;
                                    },
                                    decoration: const InputDecoration(
                                        label: Text("Playlist name")),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const FaIcon(FontAwesomeIcons.plus))
                ]
              : null,
        ),
        body: currentPlaylistIndex == null
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(playlists[index].name!),
                    subtitle: Text("${playlists[index].songs.length} songs"),
                    leading: const Icon(Icons.album),
                    onTap: () {
                      setState(() {
                        currentPlaylistIndex = index;
                      });
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Playlist actions"),
                            content: ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: const Text(
                                      "Delete playlist (Hold to confirm)"),
                                  leading: const FaIcon(FontAwesomeIcons.trash),
                                  iconColor:
                                      Theme.of(context).colorScheme.error,
                                  textColor:
                                      Theme.of(context).colorScheme.error,
                                  onLongPress: () {
                                    ref
                                        .read(playlistsProvider.notifier)
                                        .removePlaylist(playlists[index].id);
                                    ;
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
                },
                itemCount: playlists.length,
              )
            : PlaylistView(currentPlaylistIndex!),
      ),
    );
  }
}

class PlaylistView extends ConsumerStatefulWidget {
  const PlaylistView(this.playlistIndex, {super.key});
  final int playlistIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends ConsumerState<PlaylistView> {
  Audiotagger tagger = Audiotagger();

  @override
  Widget build(BuildContext context) {
    List<Playlist> playlists = ref.watch(playlistsProvider);
    return ListView.builder(
      itemBuilder: (context, index) {
        Song song = playlists[widget.playlistIndex].songs[index];
        return song.artwork == null
            ? FutureBuilder(
                future: getArtwork(song.filePath!, index),
                builder: (context, snapshot) {
                  return MusicTile(
                      snapshot.hasData
                          ? (song..artwork = snapshot.data as Uint8List)
                          : song,
                      index);
                },
              )
            : MusicTile(song, index);
      },
      itemCount: playlists[widget.playlistIndex].songs.length,
    );
  }

  ListTile MusicTile(Song song, int index) {
    return ListTile(
      title: Text(song.title!),
      leading: song.artwork == null
          ? const FaIcon(FontAwesomeIcons.music)
          : Image.memory(
              song.artwork!,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
      onTap: () => playMusic(index),
    );
  }

  getArtwork(String filepath, int index) async {
    Uint8List? artwork = await tagger.readArtwork(path: filepath);
    return artwork;
  }

  playMusic(int index) async {
    AudioPlayer player = ref.read(playerProvider);
    Playlist currentPlaylist =
        ref.read(playlistsProvider)[widget.playlistIndex];
    List<Song> songsToQueue = currentPlaylist.songs.sublist(index);

    ref.read(queueProvider.notifier).setQueue(songsToQueue);

    // var artworkTempFolder = File("${(await getTemporaryDirectory()).path}");
    // if (await artworkTempFolder.exists()) {
    //   await artworkTempFolder.delete();
    // }

    // ref.read(songProvider.notifier).setSong(song);

    // File? artworkTemp = song.artwork != null
    //     ? await File(
    //             "${artworkTempFolder.path}/${DateTime.now().microsecondsSinceEpoch}")
    //         .writeAsBytes(song.artwork!, flush: true)
    //     : null;
    // player.setAudioSource(AudioSource.uri(
    //   Uri.file(song.filePath!),
    //   tag: MediaItem(
    //     id: song.filePath!,
    //     title: song.title ?? "",
    //     artUri: artworkTemp?.uri,
    //   ),
    // ));

    await player.play();
  }
}
