import 'package:flutter/material.dart';
import 'package:auth_firebase/models/playlist_model.dart';
import 'package:auth_firebase/services/firebase_service.dart';
import 'package:auth_firebase/widgets/create_playlistsong_form.dart';
import 'package:auth_firebase/widgets/gradient_button.dart';
import 'package:auth_firebase/widgets/song/playlist_tile.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Playlist> _playlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylist();
  }

  Future<void> _fetchPlaylist() async {
    final playLists = await FirebaseService().fetchPlaylists();
    setState(() {
      _playlist = playLists;
      _isLoading = false;
    });
  }

  void _showCreatePlaylistForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePlaylistForm()),
    ).then((newPlaylist) {
      if (newPlaylist != null) {
        setState(() {
          _playlist.add(newPlaylist); // Add the new playlist directly
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/music_logoV4.png',
                        width: 60,
                      ),
                      const Text(
                        'Your Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  GradientButton(
                    label: 'Add New Playlist',
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add new playlist
                      _showCreatePlaylistForm(context);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Row(
                children: [
                  Icon(
                    Icons.sort,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Recently played',
                    style: TextStyle(
                      color: Color(0xFF00C2CB),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _playlist.length,
                      itemBuilder: (context, index) {
                        final playList = _playlist[index];
                        return PlaylistTile(
                          playlist: playList,
                          onDelete: (id) {
                            setState(() {
                              _playlist.removeWhere((p) => p.id == id);
                            });
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
