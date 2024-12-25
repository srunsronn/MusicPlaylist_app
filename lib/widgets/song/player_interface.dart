import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/screens/musicplay/music_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerInterface extends StatefulWidget {
  final AudioProvider audioProvider;

  const PlayerInterface({
    Key? key,
    required this.audioProvider,
  }) : super(key: key);

  @override
  _PlayerInterfaceState createState() => _PlayerInterfaceState();
}

class _PlayerInterfaceState extends State<PlayerInterface> {
  @override
  void initState() {
    super.initState();
    // Listen to changes in the AudioProvider
    widget.audioProvider.addListener(_updateUI);
  }

  @override
  void dispose() {
    widget.audioProvider.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestPlayedSong = widget.audioProvider.lastPlayedSong;

    // Check if the user has never listened to a song
    if (latestPlayedSong == null) {
      return const Center(
        child: Text('No song has been played yet.'),
      );
    }

    return GestureDetector(
      onTap: () {
        _playSong(context, latestPlayedSong);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 35, 30, 30),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      latestPlayedSong.coverUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestPlayedSong.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          latestPlayedSong.artist,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: () {
                      widget.audioProvider.skipPrevious();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      widget.audioProvider.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.audioProvider.isPlaying) {
                        widget.audioProvider.pause();
                      } else {
                        widget.audioProvider.play(latestPlayedSong.songUrl);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () {
                      widget.audioProvider.skipNext();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  color: Colors.grey,
                ),
                child: LinearProgressIndicator(
                  value: widget.audioProvider.songDuration.inSeconds > 0
                      ? widget.audioProvider.currentPosition.inSeconds /
                          widget.audioProvider.songDuration.inSeconds
                      : 0.0,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playSong(BuildContext context, Song song) {
    final audioProvider = widget.audioProvider;

    // Ensure the provider is updated with the new playlist
    audioProvider.loadPlaylist(audioProvider.playlist);

    // Set the current song index
    final songIndex =
        audioProvider.playlist.indexWhere((s) => s.songUrl == song.songUrl);
    if (songIndex != -1) {
      audioProvider.updateCurrentSongIndex(songIndex);
    }

    // Navigate to the MusicPlayer page with the song data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayer(
          id: song.id,
          songUrl: song.songUrl,
          coverUrl: song.coverUrl,
          songTitle: song.title,
          songArtist: song.artist,
          songList: audioProvider.playlist,
          currentSongIndex: songIndex,
        ),
      ),
    );
  }
}
