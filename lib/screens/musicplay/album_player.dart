import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/screens/musicplay/music_player.dart';
import 'package:auth_firebase/services/firebase_service.dart';
import 'package:auth_firebase/widgets/base_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumPlayer extends StatefulWidget {
  final List<Song> songs;
  final String playlistName;

  const AlbumPlayer(
      {super.key, required this.songs, required this.playlistName});

  @override
  _AlbumPlayerState createState() => _AlbumPlayerState();
}

class _AlbumPlayerState extends State<AlbumPlayer> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final songs = widget.songs;
    final coverUrl = songs.isNotEmpty
        ? songs[0].coverUrl
        : 'https://example.com/default_cover.jpg';
    final albumName = widget.playlistName;

    int numberOfSongs = songs.length;
    int totalDuration = songs.fold<int>(
      0,
      (sum, song) => sum + (song.duration?.toInt() ?? 0),
    );

    String durationFormatted = _formatDuration(totalDuration);

    return BaseLayout(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album cover and details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(coverUrl),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                // Album name
                Text(
                  albumName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Album details
                Row(
                  children: [
                    const Icon(Icons.push_pin_sharp,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "$numberOfSongs Songs",
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.access_time_sharp,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      durationFormatted,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 40,
                      decoration: BoxDecoration(
                        border:
                            Border.all(width: 1.6, color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(7),
                        image: DecorationImage(
                          image: NetworkImage(coverUrl),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Add to playlist button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(25, 25),
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 1.5),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {},
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Download button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(25, 25),
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 1.5),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        // Download the current song
                        if (_currentSongIndex < songs.length) {
                          print(
                              "Downloading song: ${songs[_currentSongIndex].id}");
                        }
                      },
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    // Shuffle button
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.shuffle,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    // Play/Pause button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFA6F3FF), Color(0xFF00C2CB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          _togglePlayPause();
                          _playSong(context, _currentSongIndex, songs);
                        },
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        iconSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10),
                // List of songs section header
                const Row(
                  children: [
                    Icon(Icons.list, color: Colors.grey, size: 30),
                    SizedBox(width: 10),
                    Text(
                      "List of songs",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // List of songs in the album
                Expanded(
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      var song = songs[index];

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            image: DecorationImage(
                              image: NetworkImage(song.coverUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          song.title ?? 'Unknown Song',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          song.artist ?? 'Unknown Artist',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          _playSong(context, index, songs);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Play or pause the song
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _playSong(BuildContext context, int index, List<Song> songs) {
    Provider.of<AudioProvider>(context, listen: false).loadPlaylist(songs);
    Provider.of<AudioProvider>(context, listen: false)
        .updateCurrentSongIndex(index);

    var song = songs[index];

    if (song != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayer(
            id: song.id,
            songUrl: song.songUrl,
            coverUrl: song.coverUrl,
            songTitle: song.title,
            songArtist: song.artist,
            songList: songs,
            currentSongIndex: index,
          ),
        ),
      );
    } else {
      print("Invalid song data at index: $index");
    }
  }
}

// Format total duration in minutes and seconds
String _formatDuration(int totalSeconds) {
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return "${minutes} min ${seconds} sec";
}
