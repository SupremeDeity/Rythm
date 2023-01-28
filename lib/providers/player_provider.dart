import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';

class SongNotifier extends Notifier<Song> {
  setSong(Song song) {
    state = song;
  }

  @override
  Song build() {
    return Song();
  }
}

final songProvider = NotifierProvider<SongNotifier, Song>(() {
  return SongNotifier();
});

class PlayerNotifier extends Notifier<AudioPlayer> {
  @override
  AudioPlayer build() {
    return AudioPlayer();
  }
}

final playerProvider =
    NotifierProvider<PlayerNotifier, AudioPlayer>(PlayerNotifier.new);
