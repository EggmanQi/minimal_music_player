import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/song.dart';

class PlaylistTile extends StatefulWidget {
  final Song? song;
  final void Function()? onTap;
  final bool? isPlaying;
  const PlaylistTile({Key? key, this.song, this.isPlaying, this.onTap}) : super(key: key);

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  void setupAnimationController() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    setupAnimationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.song!.songName),
      subtitle: Text(widget.song!.artistName),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                widget.song!.albumArtImagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (widget.isPlaying!)
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: const Icon(
                    Icons.waves,
                  ),
                );
              },
            )
        ],
      ),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      onTap: widget.onTap!,
    );
  }
}
