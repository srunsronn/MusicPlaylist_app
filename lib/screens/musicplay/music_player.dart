import 'package:auth_firebase/models/playlist_model.dart';
import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/services/firebase_service.dart';
import 'package:auth_firebase/widgets/song/player_interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicPlayer extends StatefulWidget {
  final String id;
  final String songUrl;
  final String coverUrl;
  final String songTitle;
  final String songArtist;
  final List<Song>? songList;
  final int? currentSongIndex;

  const MusicPlayer({
    required this.id,
    required this.songUrl,
    required this.coverUrl,
    required this.songTitle,
    required this.songArtist,
    this.songList,
    this.currentSongIndex,
    super.key,
  });

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  bool isMinimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.setPlaylist(widget.songList ?? []);
      audioProvider.play(widget.songUrl);

      if (widget.songList != null && widget.currentSongIndex != null) {
        audioProvider.updateCurrentSongIndex(widget.currentSongIndex!);
        audioProvider.setLastPlayedSong(widget.songUrl);
      }
    });
  }

  void _showAddToPlaylistDialog(BuildContext context, String songId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, //
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add to Playlist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Playlist>>(
                future: FirebaseService().fetchPlaylists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching playlists'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No playlists found'));
                  }

                  final playlists = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap:
                        true, // Ensure the ListView doesn't take infinite height
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: FutureBuilder<List<Song>>(
                          future: FirebaseService()
                              .fetchSongsByIds(playlist.songIds),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return const Icon(Icons.error);
                            }
                            final songs = snapshot.data ?? [];
                            final coverUrls = songs
                                .map((song) => song.coverUrl)
                                .take(4)
                                .toList();
                            return _buildCoverImages(coverUrls);
                          },
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${playlist.songIds.length} songs',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () async {
                          await FirebaseService()
                              .addSongToPlaylist(playlist.id, songId);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Song added to ${playlist.name}')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverImages(List<String> coverUrls) {
    if (coverUrls.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00C2CB), // Border color
            width: 0.9, // Border width
          ),
        ),
        child: const Icon(
          Icons.music_note,
          color: Colors.white,
          size: 30,
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF00C2CB), // Border color
          width: 1, // Border width
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: List.generate(
              coverUrls.length > 4 ? 4 : coverUrls.length, // Limit to 4 items
              (index) {
                double size = 50;
                double left = 0;
                double top = 0;

                if (coverUrls.length == 1) {
                  // Single cover, use the full ClipOval
                  size = 50;
                } else if (coverUrls.length == 2) {
                  // Two covers, each occupies half vertically
                  size = 25;
                  top = index * 25.0;
                } else if (coverUrls.length == 3) {
                  // Three covers in a triangular arrangement
                  size = 25;
                  if (index == 0) {
                    left = 12.5; // Center top cover
                  } else {
                    left = (index % 2) * 25.0;
                    top = 25.0; // Bottom row
                  }
                } else if (coverUrls.length >= 4) {
                  // Four covers in a grid
                  size = 25;
                  left = (index % 2) * 25.0;
                  top = (index ~/ 2) * 25.0;
                }

                return Positioned(
                  left: left,
                  top: top,
                  child: Image.network(
                    coverUrls[index],
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final playlist = audioProvider.playlist;
    final hasSongs = playlist.isNotEmpty && audioProvider.currentSongIndex >= 0;
    final currentSong =
        hasSongs ? playlist[audioProvider.currentSongIndex] : null;
    if (currentSong != null) {
      print('Current Song: ${currentSong.title}');
    } else {
      print('No current song playing.');
    }
    // print('Current Song: $currentSong');
    // print('Has Songs: $hasSongs');
    // print('Current Song ID: ${currentSong?.id}');

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B1B),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1C1B1B),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (hasSongs && currentSong != null && currentSong.id != null) {
                _showAddToPlaylistDialog(context, currentSong.id);
              } else {
                print('Cannot add song to playlist: Condition is false');
              }
            },
            icon: const Icon(Icons.playlist_add, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            if (currentSong != null) ...[
              _songCover(context, currentSong.coverUrl),
              const SizedBox(height: 20),
              _songDetail(currentSong.title, currentSong.artist),
              const SizedBox(height: 30),
              _songPlayer(audioProvider),
            ] else ...[
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _songCover(BuildContext context, String coverUrl) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(coverUrl.isNotEmpty
              ? coverUrl
              : 'https://via.placeholder.com/150'),
        ),
      ),
    );
  }

  Widget _songDetail(String title, String artist) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              artist,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Add favorite functionality if needed
          },
        ),
      ],
    );
  }

  Widget _songPlayer(AudioProvider audioProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Slider(
          value: audioProvider.currentPosition.inSeconds
              .toDouble()
              .clamp(0.0, audioProvider.songDuration.inSeconds.toDouble()),
          min: 0.0,
          max: audioProvider.songDuration.inSeconds > 0
              ? audioProvider.songDuration.inSeconds.toDouble()
              : 1.0,
          onChanged: (value) {
            final newPosition = Duration(seconds: value.toInt());
            audioProvider.seekTo(newPosition);
          },
          activeColor: Colors.white,
          inactiveColor: Colors.grey.shade700,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioProvider.currentPosition),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _formatDuration(audioProvider.songDuration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle, color: Colors.white),
              onPressed: () {
                // Shuffle functionality if needed
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: audioProvider.skipPrevious,
            ),
            GestureDetector(
              onTap: audioProvider.isPlaying
                  ? audioProvider.pause
                  : audioProvider.resume,
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00C2CB),
                ),
                child: Icon(
                  audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: audioProvider.skipNext,
            ),
            IconButton(
              icon: const Icon(Icons.repeat, color: Colors.white),
              onPressed: () {
                // Repeat functionality if needed
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
