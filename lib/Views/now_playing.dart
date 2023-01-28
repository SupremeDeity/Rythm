import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Widgets/player_common_utils.dart';
import 'package:rythm/Widgets/seekbar.dart';
import 'package:rythm/providers/player_provider.dart';
import 'package:rythm/providers/playlist_provider.dart';
import 'package:rythm/providers/queue_provider.dart';

class NowPlaying extends ConsumerStatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  int currentIndex = 0;
  late AudioPlayer player;

  @override
  initState() {
    setState(() {
      player = ref.read(playerProvider);
    });

    super.initState();
  }

  dialogPlaylists() {
    return IconButton(
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
                      child: const Text("Create")),
                ],
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                contentPadding: const EdgeInsets.all(16.0),
                title: const Text("Create Playlist"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        val = value;
                      },
                      decoration:
                          const InputDecoration(label: Text("Playlist name")),
                    )
                  ],
                ),
              );
            },
          ).then((value) => Navigator.of(context).pop());
        },
        icon: Icon(
          Icons.add_rounded,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ));
  }

  seekNext() async {
    await player.seekToNext();
  }

  seekPrev() async {
    await player.seekToPrevious();
  }

  @override
  Widget build(BuildContext context) {
    Song song = ref.watch(songProvider);
    List<Playlist> playlists = ref.watch(playlistsProvider);
    List<Song> queue = ref.watch(queueProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        song.artwork != null
            ? SizedBox(
                height: 500,
                child: ClipRect(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.background,
                          Colors.transparent
                        ],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            sigmaX: 10, sigmaY: 10, tileMode: TileMode.mirror),
                        child: Image.memory(
                          song.artwork!,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              )
            : Container(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(
              flex: 2,
            ),
            song.artwork != null
                ? SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(song.artwork!),
                    ),
                  )
                : const Icon(Icons.library_music, size: 150),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  song.title ??
                      song.filePath?.split("/").last.split(".").first ??
                      "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary),
                  maxLines: 3,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: "Shuffle",
                        onPressed: setShuffleMode,
                        icon: FaIcon(
                          FontAwesomeIcons.shuffle,
                          color: player.shuffleModeEnabled
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        tooltip: "Seek previous",
                        onPressed: player.hasPrevious
                            ? () {
                                seekPrev();
                              }
                            : null,
                        icon: const FaIcon(FontAwesomeIcons.backwardStep)),
                    StreamBuilder<PlayerState>(
                        stream: player.playerStateStream,
                        initialData: player.playerState,
                        builder: (context, snapshot) {
                          return FilledButton(
                              style: ButtonStyle(
                                  padding: const MaterialStatePropertyAll(
                                      EdgeInsets.all(4)),
                                  shape: const MaterialStatePropertyAll(
                                      CircleBorder()),
                                  iconSize: const MaterialStatePropertyAll(42),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).colorScheme.primary)),
                              onPressed: () =>
                                  changePlayState(snapshot, player),
                              child: snapshot.hasData
                                  ? playButtonIcon(snapshot)
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ));
                        }),
                    IconButton(
                        tooltip: "Seek next",
                        onPressed: player.hasNext
                            ? () {
                                seekNext();
                              }
                            : null,
                        icon: const FaIcon(FontAwesomeIcons.forwardStep)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                        tooltip: "Loop mode",
                        onPressed: changeLoopMode,
                        icon: StreamBuilder<LoopMode>(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data) {
                                case LoopMode.off:
                                  return const Icon(
                                    Icons.repeat,
                                    size: 30,
                                  );
                                case LoopMode.one:
                                  return Icon(
                                    Icons.repeat_one,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  );
                                case LoopMode.all:
                                  return Icon(
                                    Icons.repeat,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  );
                                default:
                                  return const FaIcon(FontAwesomeIcons.repeat);
                              }
                            }
                            return const FaIcon(FontAwesomeIcons.repeat);
                          },
                          initialData: player.loopMode,
                          stream: player.loopModeStream,
                        )),
                    IconButton(
                        tooltip: "Add to playlist",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Add to playlist"),
                                      dialogPlaylists()
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (playlists.isEmpty)
                                        Text(
                                            "No playlists created, create one to add the song to a playlist."),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            leading: const FaIcon(
                                                FontAwesomeIcons.recordVinyl),
                                            title: Text(
                                                playlists[index].name ?? ""),
                                            onTap: () {
                                              ref
                                                  .read(playlistsProvider
                                                      .notifier)
                                                  .addSong(
                                                      playlists[index], song);
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                        itemCount: playlists.length,
                                      ),
                                    ],
                                  ));
                            },
                          );
                        },
                        icon: const Icon(Icons.library_add)),
                  ],
                )
              ],
            ),
            const Seekbar(),
            const Spacer(flex: 3),
          ],
        ),
      ]),
    );
  }

  void changeLoopMode() async {
    switch (player.loopMode) {
      case LoopMode.off:
        await player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await player.setLoopMode(LoopMode.off);
        break;
    }
  }

  void setShuffleMode() async {
    await player.setShuffleModeEnabled(!player.shuffleModeEnabled);
    setState(() {}); // cause update
  }
}
