import 'package:flutter/services.dart';
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

final playerProvider = Provider<AudioPlayer>((ref) {
  AudioPlayer player = AudioPlayer();
  return player;
});
