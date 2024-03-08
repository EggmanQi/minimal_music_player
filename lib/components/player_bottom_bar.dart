import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_provider.dart';
import '../models/song.dart';

class PlayerBottomBar extends StatefulWidget {
  const PlayerBottomBar({super.key});

  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      final List<Song> playList = value.playlist;
      final song = playList[value.currentSongIndex ?? 0];
      return Container(
        height: 140, // 设置底部播放器的高度
        color: Colors.grey, // 设置底部播放器的背景颜色
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
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
                ),
                Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.songName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(song.artistName)
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    // 处理点击“上一首”按钮的逻辑
                    value.previous();
                  },
                ),
                IconButton(
                  icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    // 处理点击“播放”按钮的逻辑
                    value.pauseOrResume();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    // 处理点击“下一首”按钮的逻辑
                    value.next();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
