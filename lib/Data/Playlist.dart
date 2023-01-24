import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

part 'Playlist.g.dart';

@embedded
class Song {
  @ignore
  Uint8List? artwork;

  String? filePath;
  String? lyrics;
  String? title;
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;
  String? name;
  List<Song> songs = List.empty(growable: true);
}
