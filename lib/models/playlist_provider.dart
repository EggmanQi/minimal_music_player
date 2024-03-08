import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/song.dart';

typedef FileNotFoundCallback = void Function(bool fileExists);

class PlaylistProvider extends ChangeNotifier {
  // PlaylistProvider() {
  //   loadAssetsPath();
  // }

  // Future<String> loadAsset(String path) async {
  //   return await rootBundle.loadString(path);
  // }

  // void loadAssetsPath() async {
  // final directory = await getApplicationDocumentsDirectory();
  // final musicDirectory = Uri.parse('${directory.path}/assets/music');
  // print(musicDirectory);
  // final files = await directory.list();
  // files.map((file) {
  //   print(file);
  //   print(file.path);
  //   // print(file.lengthSync());
  // });
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Audio Player functions
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentSongDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  // error handle
  FileNotFoundCallback? _fileNotFoundCallback;
  void registerFileNotFoundCallback(FileNotFoundCallback callback) {
    _fileNotFoundCallback = callback;
  }

  // constructor
  PlaylistProvider() {
    listenToDuration();
  }

  // initially (not playing)
  bool _isPlaying = false;

  // play audio
  void play() async {
    if (_isPlaying) {
      stop();
    }
    final path = _playlist[_currentSongIndex ?? 0].audioPath;
    bool fileExists = await assetExists('assets/$path');
    if (fileExists) {
      // 文件存在
      if (_fileNotFoundCallback != null) {
        _fileNotFoundCallback!(true);
      }
      await _audioPlayer.play(AssetSource(path));
      _isPlaying = true;
      notifyListeners();
    } else {
      // 文件不存在
      if (_fileNotFoundCallback != null) {
        _fileNotFoundCallback!(false);
      }
    }
  }

  // pause
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // stop
  void stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  // resume
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  // next/previous
  void next() {
    if (_currentSongIndex == null) {
      currentSongIndex = 0;
    } else {
      if (_currentSongIndex! < _playlist.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void previous() {
    if (_currentSongDuration.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        // It depends on the 'loop' option
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  // random the list
  // seek to a specific position to the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // listen to duration
  void listenToDuration() {
    // total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    // current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentSongDuration = newPosition;
      notifyListeners();
    });
    // song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      next();
    });

    _audioPlayer.onPlayerStateChanged.listen((event) {
      // print(event);
    });
  }

  bool isPlayingAt(int index) {
    if (_currentSongIndex == index && _isPlaying) {
      return true;
    }
    return false;
  }

  // TODO: This should be a json and will load when app launch
  final List<Song> _playlist = [
    Song(
        songName: "My LoFi 01",
        artistName: "Edwin QQQ",
        albumArtImagePath: "assets/covers/cover 01.jpeg",
        audioPath: "music/cold-brew-ra-main-version-29719-02-38.mp3"),
    Song(
        songName: "Cochise x Pierre Bourne Type Beat",
        artistName: "X-lifer",
        albumArtImagePath: "assets/covers/cover 02.jpeg",
        audioPath: "music/Cochise x Pierre Bourne Type Beat- X-lifer.mp3"),
  ];

  int? _currentSongIndex;

  // Getter
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentSongDuration;
  Duration get totalDuration => _totalDuration;

  // Setter
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    // notifyListeners();
  }

  Future<bool> assetExists(String assetName) async {
    try {
      await rootBundle.load(assetName);
      return true;
    } catch (e) {
      return false;
    }
  }
}
