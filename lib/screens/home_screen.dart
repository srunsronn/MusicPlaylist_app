import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/screens/musicplay/album_player.dart';
import 'package:auth_firebase/screens/musicplay/music_player.dart';
import 'package:auth_firebase/widgets/header.dart';
import 'package:auth_firebase/widgets/song/recentlylistended.dart';
import 'package:flutter/material.dart';
import 'package:auth_firebase/screens/search/search_screen.dart';
import 'package:auth_firebase/screens/playlist/playlist_screen.dart';
import 'package:auth_firebase/screens/profile/profile_screen.dart';
import 'package:auth_firebase/widgets/song/album_display.dart';
import 'package:auth_firebase/widgets/song/playlist_song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _coverUrl;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadCoverUrl();
  }

  Future<void> _loadCoverUrl() async {
    try {
      String? savedCoverUrl = await loadCoverUrl();
      setState(() {
        _coverUrl = savedCoverUrl?.isEmpty ?? true
            ? 'https://example.com/default-cover.jpg' // Default fallback
            : savedCoverUrl;
      });
    } catch (e) {
      print("Error loading cover URL: $e");
      setState(() {
        _coverUrl = 'https://example.com/default-cover.jpg';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final lastPlayedSong = audioProvider.lastPlayedSong;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 20.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              title: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AlbumDisplay(),
                  const SizedBox(height: 30),
                  const Text(
                    "Jump Back In",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildArtistList(context),
                  // _buildPopularSongs(context),
                  const SizedBox(height: 20),
                  RecentlyListened(),
                  const SizedBox(height: 20),
                  // const PlaylistSong(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firebaseService.fetchAlbums(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading artists'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No artists found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final albums = snapshot.data!;

        // Extract unique artists from album data
        final artists = albums
            .map((album) {
              return {
                'name': album['artist'],
                'imageUrl': album['coverUrl'],
              };
            })
            .toSet()
            .toList();

        return SizedBox(
          height: 200, // Set a fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return GestureDetector(
                onTap: () async {
                  // Fetch songs for the selected artist
                  final artistAlbums = albums
                      .where((album) => album['artist'] == artist['name'])
                      .toList();

                  // Extract song IDs from the artist's albums and cast to List<String>
                  final songIds = artistAlbums
                      .expand((album) => album['songIds'])
                      .cast<String>()
                      .toList();

                  // Fetch songs by their IDs
                  final songs = await _firebaseService.fetchSongsByIds(songIds);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumPlayer(
                        playlistName: artist['name'],
                        songs: songs,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _buildArtistAvatar(artist['imageUrl'], artist['name']),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildArtistAvatar(String imageUrl, String artistName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 65, // Set the radius to 75 to make the diameter 150
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10), // Add spacing between avatar and name
        Text(
          artistName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Header();
  }

  Widget _buildPopularSongs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('songs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading popular songs'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No popular songs found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final songs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPopularSongsHeader(),
            const SizedBox(height: 10),
            _buildSongsList(songs, context),
          ],
        );
      },
    );
  }

  Widget _buildPopularSongsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Popular Songs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Implement navigation to show all songs
          },
          child: Text(
            "Show all",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildSongsList(List songs, BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(song['coverUrl']),
          ),
          title: Text(
            song['title'],
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            song['artist'],
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            String songCoverUrl = song['coverUrl'];
            // Save the cover URL when a song is tapped
            saveCoverUrl(songCoverUrl);
            Provider.of<AudioProvider>(context, listen: false)
                .setLastPlayedSong(song['songUrl']); // Set last played song
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayer(
                  id: song['id'],
                  songUrl: song['songUrl'],
                  coverUrl: songCoverUrl,
                  songTitle: song['title'],
                  songArtist: song['artist'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> saveCoverUrl(String coverUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coverUrl', coverUrl);
  }

  Future<String?> loadCoverUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('coverUrl');
  }
}
