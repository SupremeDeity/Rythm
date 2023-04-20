import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
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

class ArtworkDomColorNotifier extends AsyncNotifier<PaletteGenerator?> {
  @override
  build() async {
    var song = ref.watch(songProvider);
    if (song.artwork != null) {
      var paletteGen = await PaletteGenerator.fromImageProvider(
          Image.memory(song.artwork!).image);
      return paletteGen;
    }
    return null;
  }
}

final artworkDomColorProvider =
    AsyncNotifierProvider<ArtworkDomColorNotifier, PaletteGenerator?>(
        ArtworkDomColorNotifier.new);

class PlayerNotifier extends Notifier<AudioPlayer> {
  @override
  AudioPlayer build() {
    return AudioPlayer();
  }
}

final playerProvider =
    NotifierProvider<PlayerNotifier, AudioPlayer>(PlayerNotifier.new);
