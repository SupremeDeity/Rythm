import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Data/Playlist.dart';
import 'package:rythm/Views/browse.dart';
import 'package:rythm/Views/playlists_browse.dart';
import 'package:rythm/Views/settings_view.dart';
import 'package:rythm/Widgets/now_playing_sheet.dart';
import 'package:rythm/providers/player_provider.dart';
import 'package:rythm/providers/queue_provider.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  bool playing = false;
  StreamSubscription<int?>? indexSub;
  late AudioPlayer player;

  @override
  initState() {
    super.initState();
    if (mounted) {
      setState(() {
        player = ref.read(playerProvider);
        playing = player.playing;
      });
      indexSub = player.currentIndexStream.listen((event) {
        if (event != null && ref.read(queueProvider).isNotEmpty) {
          ref.read(queueProvider.notifier).setQueueIndex(event);
        }
      });
    }
  }

  @override
  void dispose() {
    indexSub!.cancel();

    super.dispose();
  }

  var routes = [
    const Browse(),
    const PlaylistsBrowse(),
    const SettingsView(),
  ];

  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Song song = ref.watch(songProvider);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: routes),
      bottomSheet: song.filePath != null ? NowPlayingSheet() : null,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.list,
              size: 20,
            ),
            activeIcon: FaIcon(
              FontAwesomeIcons.listOl,
              size: 20,
            ),
            label: "Browse",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.music_note_outlined,
              ),
              activeIcon: Icon(
                Icons.music_note,
              ),
              label: "Playlist"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings_outlined,
              ),
              activeIcon: Icon(
                Icons.settings,
              ),
              label: "Settings")
        ],
        currentIndex: _currentIndex,
        onTap: (itemIndex) {
          if (itemIndex != _currentIndex) {
            setState(() {
              _currentIndex = itemIndex;
            });
          }
        },
      ),
    );
  }
}
