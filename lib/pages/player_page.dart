import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:minimal_music_player/components/neu_box.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

import 'dart:ui' show ParagraphBuilder, ParagraphConstraints;

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _isTextOverflow(BuildContext context, double maxWidth, String text, TextStyle style) {
    final paragraphStyle = style.getParagraphStyle(maxLines: 1);
    final paragraphBuilder = ParagraphBuilder(paragraphStyle)
      ..pushStyle(style.getTextStyle())
      ..addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ParagraphConstraints(width: maxWidth));
    return paragraph.didExceedMaxLines;
  }

  String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String twoDigitMinutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      // 1. Get playlist
      final playlist = value.playlist; // MARK: 这里 value 相当于观察者直接返回 provider 本体
      // 2. get current song (index)
      final currentSong = playlist[value.currentSongIndex ?? 0];

      /* Question: 在没有用 Z 轴布局组件的情况下, 文本的绘制会超出父 widget 的范围, 
                    从而影响到收藏按钮的绘制
         Solution: 1. 获取屏幕宽度, 通过 padding 来方向计算出文本可显示范围(Why? layout builder 返回的父 widget 约束是 infinity 😊)
                   2. 在(1)的基础上, 计算出将要显示的文本是否会超出范围
                   3. 如果超出了范围, 使用 Marquee 走马灯, 滚动显示完整文本
                   4. 如果没有超出, 使用普通的 Text 来显示
         Other solution: 可以使用 SizeBox + AutoSizeText 来做缩放兼容, 减少计算量
      */
      final screenWidth = MediaQuery.of(context).size.width;

      // 3. return UI
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text("P L A Y E R"),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  ],
                ),
                const Spacer(),
                // art work
                NeoBox(
                  child: Column(
                    children: [
                      Image.asset(
                        currentSong.albumArtImagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        width: screenWidth - 50,
                        height: screenWidth - 50,
                      ),
                      // song name & artist name
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 最终方案
                                LayoutBuilder(builder: (context, constraints) {
                                  final isTextOverflow = _isTextOverflow(
                                      context,
                                      screenWidth - 120.0,
                                      currentSong.songName,
                                      const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
                                  return isTextOverflow
                                      ? SizedBox(
                                          width: screenWidth - 120.0,
                                          height: 40,
                                          child: Marquee(
                                            blankSpace: 50,
                                            velocity: 20,
                                            fadingEdgeStartFraction: 0.1,
                                            fadingEdgeEndFraction: 0.1,
                                            text: currentSong.songName,
                                            style: const TextStyle(
                                                fontSize: 20.0, fontWeight: FontWeight.bold),
                                          ))
                                      : SizedBox(
                                          height: 40,
                                          child: Center(
                                            child: Text(currentSong.songName,
                                                style: const TextStyle(
                                                    fontSize: 20.0, fontWeight: FontWeight.bold)),
                                          ));
                                  // return Text(
                                  // 'The parent constraints ${constraints.maxWidth} x ${constraints.maxHeight}');
                                }),
                                Text(currentSong.artistName),
                              ],
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                // play duration
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatTime(value.currentDuration)),
                              // Icon(Icons.shuffle),
                              // Icon(Icons.repeat),
                              Text(formatTime(value.totalDuration))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0.1,
                      )),
                      child: Slider(
                        value: value.currentDuration.inSeconds.toDouble(),
                        min: 0,
                        max: value.totalDuration.inSeconds.toDouble(),
                        inactiveColor: Theme.of(context).colorScheme.primary,
                        activeColor: Theme.of(context).colorScheme.inversePrimary,
                        onChanged: (progress) {},
                        onChangeEnd: (position) {
                          value.seek(Duration(seconds: position.toInt()));
                        },
                      ),
                    ),
                  ],
                ),
                // playback controls
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // skip previous
                    Expanded(
                        child: GestureDetector(
                            onTap: value.previous,
                            child: const NeoBox(child: Icon(Icons.skip_previous)))),
                    const SizedBox(
                      width: 16,
                    ),
                    // play or pause
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: value.pauseOrResume,
                            child: NeoBox(
                                child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow)))),
                    const SizedBox(
                      width: 16,
                    ),
                    // skip forward
                    Expanded(
                        child: GestureDetector(
                            onTap: value.next, child: const NeoBox(child: Icon(Icons.skip_next)))),
                  ],
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      );
    });
  }
}
