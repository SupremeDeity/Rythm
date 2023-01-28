import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Widget playButtonIcon(AsyncSnapshot<PlayerState> snapshot) {
  switch (snapshot.data!.processingState) {
    case ProcessingState.loading:
    case ProcessingState.buffering:
      return const CircularProgressIndicator();
    case ProcessingState.ready:
      if (snapshot.data!.playing) {
        return const Icon(Icons.pause_rounded);
      }
      return const Icon(Icons.play_arrow_rounded);
    case ProcessingState.idle:
    case ProcessingState.completed:
      return const Icon(Icons.replay);
    default:
      return const Icon(Icons.play_arrow_rounded);
  }
}

void changePlayState(AsyncSnapshot<PlayerState> snapshot, AudioPlayer player) {
  if (snapshot.hasData) {
    if (snapshot.data!.processingState == ProcessingState.completed) {
      player.seek(Duration.zero, index: 0);
    } else if (snapshot.data!.playing) {
      player.pause();
    } else {
      player.play();
    }
  }
}
