import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class Song {
  String? filePath;
  Uint8List? artwork;
}

class SongNotifier extends StateNotifier<Song> {
  SongNotifier() : super(Song());

  setSong(Song song) {
    state = song;
  }
}

final songProvider = StateNotifierProvider<SongNotifier, Song>((ref) {
  return SongNotifier();
});

final playerProvider = Provider<AudioPlayer>((ref) {
  AudioPlayer player = AudioPlayer();
  return player;
});
