import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      )
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
