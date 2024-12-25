import 'package:auth_firebase/screens/musicplay/album_player.dart';
import 'package:flutter/material.dart';
import 'package:auth_firebase/services/firebase_service.dart';
import 'package:auth_firebase/models/song_model.dart';

class AlbumDisplay extends StatefulWidget {
  @override
  _AlbumDisplayState createState() => _AlbumDisplayState();
}

class _AlbumDisplayState extends State<AlbumDisplay> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = _firebaseService.fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Album List",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _albumsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching albums'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No albums available'));
            }

            List<Map<String, dynamic>> albums = snapshot.data!;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return GestureDetector(
                  onTap: () async {
                    final songs = await _firebaseService
                        .fetchAlbumSongs(album['albumId']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => AlbumPlayer(
                          playlistName: album['name'],
                          songs: songs,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 63,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: NetworkImage(album['coverUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            album['name'] ?? 'Unknown Album',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
