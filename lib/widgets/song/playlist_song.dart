import 'package:auth_firebase/screens/musicplay/music_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaylistSong extends StatefulWidget {
  const PlaylistSong({super.key});

  @override
  _PlaylistSongState createState() => _PlaylistSongState();
}

class _PlaylistSongState extends State<PlaylistSong> {
  bool showAllSongs = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'See More',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xffC6C6C6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fetch songs from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  "No songs found",
                  style: TextStyle(color: Colors.grey),
                );
              }

              final songs = snapshot.data!.docs;
              final songsToDisplay =
                  showAllSongs ? songs : songs.take(4).toList();

              return ListView.separated(
                shrinkWrap: true,
                itemCount: songsToDisplay.length,
                itemBuilder: (context, index) {
                  final song = songsToDisplay[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayer(
                            id: song.id,
                            songUrl: song['songUrl'],
                            coverUrl: song['coverUrl'],
                            songTitle: song['title'],
                            songArtist: song['artist'],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Play button icon
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white, // Light grey color
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(
                                    0xff555555), // Darker color for the play icon
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Song title
                                Text(
                                  song['title'] ?? 'Unknown title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Song artist
                                Text(
                                  song['artist'] ?? 'Unknown artist',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    color: Color(0xff555555),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Song duration
                            Text(
                              _formatDuration(song['duration']),
                              style: const TextStyle(
                                color: Color(0xff555555),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Favorite button
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                                // Handle the favorite button press
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
              );
            },
          ),

          // See More button
          if (showAllSongs) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  showAllSongs = false; // Show fewer songs
                });
              },
              child: const Text(
                'Show Less',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xffC6C6C6),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  showAllSongs = true; // Show all songs
                });
              },
              child: const Text(
                'See More',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xffC6C6C6),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Helper method to format duration from seconds to "mm:ss"
  String _formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
