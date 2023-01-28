import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/providers/player_provider.dart';

class QueueNotifier extends Notifier<List<Song>> {
  /// [setQueue] creates a [ConcatenatingAudioSource] *only* when [songs]
  /// length > 1 to not cause issues with player.
  ///
  /// `shuffleByDefault` is set to true only when playing an entire playlist,
  /// to not cause issue when the queue starts from playlist browser.
  setQueue(List<Song> songs, {bool shuffleByDefault = false}) async {
    var player = ref.read(playerProvider);
    var artworkTempFolder = File((await getTemporaryDirectory()).path);
    if (await artworkTempFolder.exists()) {
      await artworkTempFolder.delete();
    }
    List<AudioSource> queue = [];

    for (Song song in songs) {
      File? artworkTemp = song.artwork != null
          ? await File(
                  "${artworkTempFolder.path}/${DateTime.now().microsecondsSinceEpoch}")
              .writeAsBytes(song.artwork!)
          : null;

      queue.add(AudioSource.uri(Uri.file(song.filePath!),
          tag: MediaItem(
              id: song.filePath!,
              title: song.title!,
              artUri: artworkTemp?.uri)));
    }

    var cas = songs.length > 1
        ? ConcatenatingAudioSource(children: queue)
        : queue.first;

    await player.setShuffleModeEnabled(shuffleByDefault);
    await player.setAudioSource(cas);

    ref.read(songProvider.notifier).setSong(songs[player.currentIndex ?? 0]);

    state = [...songs];
  }

  setQueueIndex(int index) {
    ref.read(songProvider.notifier).setSong(state[index]);
    state = [...state];
  }

  @override
  List<Song> build() {
    return [];
  }
}

final queueProvider =
    NotifierProvider<QueueNotifier, List<Song>>(QueueNotifier.new);
