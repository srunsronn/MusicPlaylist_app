import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/screens/musicplay/music_player.dart';
import 'package:auth_firebase/models/song_model.dart';

class RecentlyListened extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final recentlyListened = audioProvider.lastPlayedSongs;

        // Print the data of the list of songs that were recently played
        // print('Recently Listened Songs: $recentlyListened');

        if (recentlyListened.isEmpty) {
          return const Center(
              child: Text('No recently listened songs available'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recently Listened',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 120, // Adjusted height for better visibility
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyListened.take(6).length,
                itemBuilder: (context, index) {
                  final song = recentlyListened[index];
                  return GestureDetector(
                    onTap: () {
                      _playSong(context, index, recentlyListened);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
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
                        // border: Border.all(color: Colors.white, wid),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                song.coverUrl,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _playSong(BuildContext context, int index, List<Song> songs) {
    // Ensure the provider is updated with the new playlist
    Provider.of<AudioProvider>(context, listen: false).loadPlaylist(songs);

    // Set the current song index
    Provider.of<AudioProvider>(context, listen: false)
        .updateCurrentSongIndex(index);

    // Get the selected song to pass into the MusicPlayer
    var song = songs[index];

    if (song != null) {
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
