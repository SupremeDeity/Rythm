import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Views/now_playing.dart';
import 'package:rythm/providers/player_provider.dart';

class NowPlayingSheet extends ConsumerStatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  NowPlayingSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NowPlayingSheetState();
}

class _NowPlayingSheetState extends ConsumerState<NowPlayingSheet> {
  @override
  Widget build(BuildContext context) {
    AudioPlayer player = ref.watch(playerProvider);
    Song songMetadata = ref.watch(songProvider);
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => const NowPlaying()),
      ),
      dense: true,
      isThreeLine: true,
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      leading: songMetadata.artwork != null
          ? Image.memory(songMetadata.artwork!)
          : const Icon(Icons.music_note),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          songMetadata.filePath?.split("/").last ?? "Text",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      minVerticalPadding: 10,
      subtitle: StreamBuilder<Duration>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LinearProgressIndicator(
              value: ((snapshot.data?.inMilliseconds ?? 1) /
                      (player.duration?.inMilliseconds ?? 1))
                  .clamp(0, 1),
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            );
          }
          return const Icon(Icons.play_arrow);
        },
        initialData: Duration.zero,
        stream: player.positionStream,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }
}
