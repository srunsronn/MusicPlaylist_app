import 'package:auth_firebase/firebase_options.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/screens/musicplay/album_player.dart';
import 'package:auth_firebase/screens/playlist/playlist_screen.dart';
import 'package:auth_firebase/screens/profile/profile_screen.dart';
import 'package:auth_firebase/screens/search/search_screen.dart';
import 'package:auth_firebase/utils/app_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:auth_firebase/screens/auth/signup.dart';
import 'package:auth_firebase/screens/home_screen.dart';
import 'package:auth_firebase/screens/splash/splash_screen.dart';
import 'package:auth_firebase/screens/splash/get_started.dart';
import 'package:auth_firebase/screens/auth/signin.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;
  String? userId = user?.uid;
  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioProvider(userId),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/get-started': (context) => const GetStarted(),
        '/signin': (context) => const Signin(),
        '/signup': (context) => const Signup(),
        '/home': (context) => AppWrapper(),
        '/search': (context) => AppWrapper(),
        '/library': (context) => AppWrapper(),
        '/profile': (context) => AppWrapper(),
        '/album': (context) => const AlbumPlayer(songs: [], playlistName: ''),
      },
    );
  }
}
