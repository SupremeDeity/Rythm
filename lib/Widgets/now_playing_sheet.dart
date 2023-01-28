import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Views/now_playing.dart';
import 'package:rythm/Widgets/player_common_utils.dart';
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
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      leading: songMetadata.artwork != null
          ? Image.memory(
              songMetadata.artwork!,
              fit: BoxFit.fill,
            )
          : const Icon(Icons.music_note),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          songMetadata.title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      minVerticalPadding: 20,
      visualDensity: VisualDensity.comfortable,
      subtitle: StreamBuilder<Duration>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LinearProgressIndicator(
              value: ((snapshot.data?.inMilliseconds ?? 0) /
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
          StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              initialData: player.playerState,
              builder: (context, snapshot) {
                return IconButton(
                    iconSize: 32,
                    onPressed: () {
                      changePlayState(snapshot, player);
                    },
                    icon: snapshot.hasData
                        ? playButtonIcon(snapshot)
                        : const Center(
                            child: CircularProgressIndicator(),
                          ));
              }),
        ],
      ),
    );
  }
}
