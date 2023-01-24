import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Widgets/seekbar.dart';
import 'package:rythm/providers/player_provider.dart';

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
                            sigmaX: 15, sigmaY: 15, tileMode: TileMode.mirror),
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
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                song.filePath?.split("/").last.split(".").first ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: player.hasPrevious
                        ? () {
                            player.seekToPrevious();
                          }
                        : null,
                    icon: FaIcon(FontAwesomeIcons.backwardStep)),
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
                                return const FaIcon(FontAwesomeIcons.pause);
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
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              );
                            case LoopMode.all:
                              return Icon(
                                Icons.repeat,
                                color: Theme.of(context).colorScheme.primary,
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
                    ))
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
