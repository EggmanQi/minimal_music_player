import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/drawer.dart';
import 'package:minimal_music_player/components/playlist_tile.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/pages/player_page.dart';
import 'package:provider/provider.dart';
import '../components/player_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerPage()));
    playlistProvider.currentSongIndex = songIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("P L A Y L I S T"),
      ),
      drawer: const MyDrawer(),
      bottomNavigationBar: const PlayerBottomBar(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playList = value.playlist;
          return ListView.builder(
              itemCount: playList.length,
              itemBuilder: (context, index) {
                final song = playList[index];
                value.registerFileNotFoundCallback((bool fileExists) {
                  if (fileExists) {
                    // goToSong(index);
                  } else {
                    // 文件不存在时的处理逻辑，例如显示一个提示框
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('错误'),
                        content: Text('没有找到文件'),
                      ),
                    );
                  }
                });
                return PlaylistTile(
                  song: song,
                  isPlaying: value.isPlayingAt(index),
                  onTap: () {
                    // value.play();
                    goToSong(index);
                  },
                );
              });
        },
      ),
    );
  }
}
