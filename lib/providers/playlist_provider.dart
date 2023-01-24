import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Data/database.dart';

class PlaylistsNotifier extends Notifier<List<Playlist>> {
  /// Sets playlist state.
  ///
  /// NOTE: DOES NOT MODIFY ISAR DB
  setPlaylists(List<Playlist> playlists) {
    state = playlists;
  }

  /// Sets playlist state.
  ///
  /// NOTE: MODIFIES ISAR DB
  addPlaylist(Playlist playlist) async {
    state = [...state, playlist];
    isarDB.writeTxn(() async {
      isarDB.playlists.put(playlist);
    });
  }

  /// Removes playlist from state.
  ///
  /// NOTE: MODIFIES ISAR DB
  removePlaylist(int id) async {
    state = [
      for (var playlist in state)
        if (playlist.id != id) playlist
    ];
    await isarDB.writeTxn(() async {
      await isarDB.playlists.delete(id);
    });
  }

  /// Adds song to playlist.
  ///
  /// NOTE: MODIFIES ISAR DB
  addSong(Playlist playlist, Song song) async {
    for (var plSong in playlist.songs) {
      if (plSong.filePath == song.filePath) return;
    }
    Playlist newPlaylist = Playlist()
      ..id = playlist.id
      ..name = playlist.name
      ..songs = List.from(playlist.songs);
    newPlaylist.songs.add(song);
    List<Playlist> newList = [];
    for (var stPlaylist in state) {
      if (playlist.id == stPlaylist.id) {
        newList.add(newPlaylist);
      } else {
        newList.add(stPlaylist);
      }
    }
    state = newList;

    await isarDB.writeTxn(() async {
      await isarDB.playlists
          .put(state.firstWhere((element) => element.id == playlist.id));
    });
  }

  @override
  List<Playlist> build() {
    return [];
  }
}

final playlistsProvider =
    NotifierProvider<PlaylistsNotifier, List<Playlist>>(() {
  return PlaylistsNotifier();
});
