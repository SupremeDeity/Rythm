import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/providers/player_provider.dart';

class Seekbar extends ConsumerStatefulWidget {
  const Seekbar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SeekbarState();
}

class _SeekbarState extends ConsumerState<Seekbar> {
  double value = 0.0;
  @override
  Widget build(BuildContext context) {
    AudioPlayer player = ref.read(playerProvider);
    Song song = ref.watch(songProvider);
    return StreamBuilder<Duration>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Theme.of(context).colorScheme.tertiary,
                  thumbColor: Theme.of(context).colorScheme.secondary,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  label: Duration(
                          milliseconds:
                              (value * (player.duration?.inMilliseconds ?? 1))
                                  .ceil())
                      .toString()
                      .split(".")[0],
                  value: ((snapshot.data?.inMilliseconds ?? 1) /
                          (player.duration?.inMilliseconds ?? 1))
                      .clamp(0, 1),
                  onChanged: (val) {
                    setState(() {
                      value = val;
                    });
                  },
                  onChangeEnd: (value) {
                    player.seek(Duration(
                        milliseconds:
                            (value * (player.duration?.inMilliseconds ?? 1))
                                .ceil()));
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Text(snapshot.data.toString().split(".")[0]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Text(player.duration.toString().split(".")[0]),
                  ),
                ],
              ),
            ],
          );
        }
        return const FaIcon(FontAwesomeIcons.play);
      },
      initialData: Duration.zero,
      stream: player.positionStream,
    );
  }
}
