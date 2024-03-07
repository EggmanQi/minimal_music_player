import 'package:flutter/material.dart';
import 'package:minimal_music_player/themes/dark.dart';
import 'package:minimal_music_player/themes/light.dart';

class ThemeProvider extends ChangeNotifier {
  // initially value is light mode
  ThemeData _themeData = lightMode;

  // get method
  ThemeData get themeData => _themeData;

  // judge is light or dark
  bool get isDarkMode => _themeData == darkMode;

  // set value, and notify app when mode is change
  // MARK: not work
  // set themeData(ThemeData themeData) {
  //   _themeData = themeData;
  //   notifyListeners();
  // }

  // toggle for outside
  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }
}
