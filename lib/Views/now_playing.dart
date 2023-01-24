import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Widgets/seekbar.dart';
import 'package:rythm/providers/player_provider.dart';
import 'package:rythm/providers/playlist_provider.dart';

class NowPlaying extends ConsumerStatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  @override
  Widget build(BuildContext context) {
    AudioPlayer player = ref.read(playerProvider);
    Song song = ref.watch(songProvider);
    List<Playlist> playlists = ref.watch(playlistsProvider);
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
                          Theme.of(context).backgroundColor,
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
                          song.artwork! as Uint8List,
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
              flex: 3,
            ),
            song.artwork != null
                ? SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(song.artwork! as Uint8List),
                    ),
                  )
                : const Icon(Icons.library_music, size: 150),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                song.title ??
                    song.filePath?.split("/").last.split(".").first ??
                    "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: player.hasPrevious
                              ? () {
                                  player.seekToPrevious();
                                }
                              : null,
                          icon: const FaIcon(FontAwesomeIcons.backwardStep)),
                      IconButton(
                          onPressed: () {
                            if (player.playing) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                          icon: StreamBuilder<PlayerState>(
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                switch (snapshot.data!.processingState) {
                                  case ProcessingState.loading:
                                  case ProcessingState.buffering:
                                    return const CircularProgressIndicator();
                                  case ProcessingState.ready:
                                    if (snapshot.data!.playing) {
                                      return const FaIcon(
                                          FontAwesomeIcons.pause);
                                    }
                                    return const FaIcon(FontAwesomeIcons.play);
                                  case ProcessingState.idle:
                                  case ProcessingState.completed:
                                    return const FaIcon(FontAwesomeIcons.play);
                                  default:
                                    return const FaIcon(FontAwesomeIcons.play);
                                }
                              }
                              return const FaIcon(FontAwesomeIcons.play);
                            },
                            initialData: player.playerState,
                            stream: player.playerStateStream,
                          )),
                      IconButton(
                          onPressed: player.hasNext
                              ? () {
                                  player.seekToNext();
                                }
                              : null,
                          icon: FaIcon(FontAwesomeIcons.forwardStep)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          switch (player.loopMode) {
                            case LoopMode.off:
                              player.setLoopMode(LoopMode.one);
                              break;
                            case LoopMode.one:
                              player.setLoopMode(LoopMode.all);
                              break;
                            case LoopMode.all:
                              player.setLoopMode(LoopMode.off);
                              break;
                          }
                        },
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Add to playlist"),
                                content: ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading:
                                          FaIcon(FontAwesomeIcons.recordVinyl),
                                      title: Text(playlists[index].name ?? ""),
                                      onTap: () {
                                        ref
                                            .read(playlistsProvider.notifier)
                                            .addSong(playlists[index], song);
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  itemCount: playlists.length,
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.library_add)),
                  ],
                )
              ],
            ),
            Seekbar(),
            const Spacer(flex: 3),
          ],
        ),
      ]),
    );
  }
}
