import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/drawer.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/pages/player_page.dart';
import 'package:provider/provider.dart';
import 'player_bottom_bar.dart';

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
      bottomNavigationBar: PlayerBottomBar(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playList = value.playlist;
          return ListView.builder(
              itemCount: playList.length,
              itemBuilder: (context, index) {
                final song = playList[index];
                return ListTile(
                  title: Text(song.songName),
                  subtitle: Text(song.artistName),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        song.albumArtImagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    goToSong(index);
                  },
                );
              });
        },
      ),
    );
  }
}
