import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth_firebase/models/song_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier, WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _audioSession;

  bool _isPlaying = false;
  bool _isActive = true;
  Duration _currentPosition = Duration.zero;
  Duration _songDuration = Duration.zero;

  List<Song> _playlist = [];
  int _currentSongIndex = -1;
  Song? lastPlayedSong;
  List<Song> _lastPlayedSongs = [];

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get songDuration => _songDuration;

  List<Song> get playlist => _playlist;
  List<Song> get lastPlayedSongs => _lastPlayedSongs;
  int get currentSongIndex => _currentSongIndex;

  String? userId; // Identifier for the user

  AudioProvider(this.userId) {
    WidgetsBinding.instance.addObserver(this);
    _initAudioSession();
    _loadLastPlayedSong();
    _loadCurrentSongIndex();
    _loadLastPlayedSongs();

    _audioPlayer.onDurationChanged.listen((duration) {
      _songDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (_isPlaying) {
        _currentPosition = position;
        notifyListeners();
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      skipNext();
    });
  }

  Future<void> _initAudioSession() async {
    _audioSession = await AudioSession.instance;
    await _audioSession!.configure(AudioSessionConfiguration.music());
    await _audioSession!.setActive(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pause();
      _isActive = false;
    } else if (state == AppLifecycleState.resumed) {
      _isActive = true;
    }
  }

  Future<void> _loadLastPlayedSong() async {
    final prefs = await SharedPreferences.getInstance();
    final songId = prefs.getString('${userId}_lastPlayedSongId');
    final songUrl = prefs.getString('${userId}_lastPlayedSongUrl');
    final songTitle = prefs.getString('${userId}_lastPlayedSongTitle');
    final songArtist = prefs.getString('${userId}_lastPlayedSongArtist');
    final songCoverUrl = prefs.getString('${userId}_lastPlayedSongCoverUrl');

    if (songId != null &&
        songUrl != null &&
        songTitle != null &&
        songArtist != null &&
        songCoverUrl != null) {
      lastPlayedSong = Song(
        id: songId,
        songUrl: songUrl,
        title: songTitle,
        artist: songArtist,
        coverUrl: songCoverUrl,
      );
      print('Loaded last played song: $lastPlayedSong');
      await _loadPlaylistAndSetLastSong();
      notifyListeners();
    }
  }

  Future<void> _saveLastPlayedSongDetails(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${userId}_lastPlayedSongId', song.id);
    await prefs.setString('${userId}_lastPlayedSongUrl', song.songUrl);
    await prefs.setString('${userId}_lastPlayedSongTitle', song.title);
    await prefs.setString('${userId}_lastPlayedSongArtist', song.artist);
    await prefs.setString('${userId}_lastPlayedSongCoverUrl', song.coverUrl);
  }

  void setLastPlayedSong(String songUrl) {
    final song = _playlist.firstWhere(
      (song) => song.songUrl == songUrl,
      orElse: () => Song(
        id: "",
        songUrl: "",
        title: "Unknown",
        artist: "Unknown",
        coverUrl: '',
      ),
    );

    if (song.songUrl.isNotEmpty) {
      lastPlayedSong = song;
      _saveLastPlayedSongDetails(song);
      print('Set last played song: $lastPlayedSong');
    } else {
      lastPlayedSong = null;
    }

    notifyListeners();
  }

  void setCurrentSongFromLastPlayed() {
    if (lastPlayedSong != null) {
      final songIndex = _playlist
          .indexWhere((song) => song.songUrl == lastPlayedSong!.songUrl);
      if (songIndex != -1) {
        _currentSongIndex = songIndex;
      } else {
        _playlist.insert(0, lastPlayedSong!);
        _currentSongIndex = 0;
      }
      notifyListeners();
    }
  }

  void loadPlaylist(List<Song> songs) {
    _playlist = songs;
    notifyListeners();
  }

  void updateCurrentSongIndex(int index) {
    _currentSongIndex = index;
    play(_playlist[_currentSongIndex].songUrl);
    notifyListeners();
  }

  void setPlaylist(List<Song> playlist) {
    _playlist = playlist;
    _currentSongIndex = playlist.isNotEmpty ? 0 : -1;
    if (_playlist.isNotEmpty) {
      play(_playlist[_currentSongIndex].songUrl);
    } else {
      _isPlaying = false;
    }
    notifyListeners();
  }

  Future<void> play(String url) async {
    if (_isActive) {
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      _isPlaying = true;

      if (url.isNotEmpty) {
        setLastPlayedSong(url);
        addLastPlayedSong(_playlist[_currentSongIndex]);
      }

      notifyListeners();
    } else {
      print("App is inactive, cannot play audio.");
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> skipNext() async {
    if (_playlist.isNotEmpty) {
      if (_currentSongIndex < _playlist.length - 1) {
        _currentSongIndex++;
      } else {
        _currentSongIndex = 0;
      }
      await play(_playlist[_currentSongIndex].songUrl);
      notifyListeners();
    }
  }

  Future<void> skipPrevious() async {
    if (_playlist.isNotEmpty) {
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        _currentSongIndex = _playlist.length - 1;
      }
      await play(_playlist[_currentSongIndex].songUrl);
      notifyListeners();
    }
  }

  Future<void> _saveCurrentSongIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${userId}_currentSongIndex', index);
  }

  Future<void> _loadCurrentSongIndex() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSongIndex = prefs.getInt('${userId}_currentSongIndex') ?? -1;
    notifyListeners();
  }

  Future<void> _saveLastPlayedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> songList =
        _lastPlayedSongs.map((song) => jsonEncode(song.toMap())).toList();
    await prefs.setStringList('${userId}_lastPlayedSongs', songList);
  }

  Future<void> _loadLastPlayedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? songList = prefs.getStringList('${userId}_lastPlayedSongs');
    if (songList != null) {
      _lastPlayedSongs =
          songList.map((song) => Song.fromMap(jsonDecode(song))).toList();
      notifyListeners();
    }
  }

  void addLastPlayedSong(Song song) {
    _lastPlayedSongs.removeWhere((s) => s.songUrl == song.songUrl);
    _lastPlayedSongs.insert(0, song);
    if (_lastPlayedSongs.length > 10) {
      _lastPlayedSongs = _lastPlayedSongs.sublist(0, 10);
    }
    _saveLastPlayedSongs();
    notifyListeners();
  }

  Future<void> _loadPlaylistAndSetLastSong() async {
    if (lastPlayedSong != null) {
      final songIndex = _playlist
          .indexWhere((song) => song.songUrl == lastPlayedSong!.songUrl);
      if (songIndex != -1) {
        _currentSongIndex = songIndex;
      } else {
        _playlist.insert(0, lastPlayedSong!);
        _currentSongIndex = 0;
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }
}
