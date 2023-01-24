import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/providers/player_provider.dart';

class Seekbar extends ConsumerStatefulWidget {
  const Seekbar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SeekbarState();
}

class _SeekbarState extends ConsumerState<Seekbar> {
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
                    thumbColor: Theme.of(context).colorScheme.secondary,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)),
                child: Slider(
                  value: ((snapshot.data?.inMilliseconds ?? 1) /
                          (player.duration?.inMilliseconds ?? 1))
                      .clamp(0, 1),
                  onChanged: (value) {},
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
