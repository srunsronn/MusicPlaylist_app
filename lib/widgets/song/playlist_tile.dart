import 'package:auth_firebase/screens/musicplay/album_player.dart';
import 'package:flutter/material.dart';
import 'package:auth_firebase/models/playlist_model.dart';
import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/services/firebase_service.dart';

class PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  final Function(String) onDelete;

  PlaylistTile({Key? key, required this.playlist, required this.onDelete})
      : super(key: key);

  @override
  _PlaylistTileState createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showCRUDModal(context, widget.playlist);
      },
      child: ListTile(
        leading: FutureBuilder<List<Song>>(
          future: _fetchSongs(widget.playlist.songIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Icon(Icons.error);
            }
            final songs = snapshot.data ?? [];
            final coverUrls =
                songs.map((song) => song.coverUrl).take(4).toList();
            return _buildCoverImages(coverUrls);
          },
        ),
        title: Text(
          widget.playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${widget.playlist.songIds.length} songs',
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        onTap: () async {
          final songs = await _fetchSongs(widget.playlist.songIds);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumPlayer(
                songs: songs,
                playlistName: widget.playlist.name,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Song>> _fetchSongs(List<String> songIds) async {
    return await _firebaseService.fetchSongsByIds(songIds);
  }

  Widget _buildCoverImages(List<String> coverUrls) {
    if (coverUrls.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: const Color(0xFF00C2CB),
            width: 0.9,
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
        borderRadius: BorderRadius.circular(10),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: const Color(0xFF00C2CB),
          width: 1,
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

  void _showCRUDModal(BuildContext context, Playlist playlist) {
    TextEditingController nameController =
        TextEditingController(text: playlist.name);
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: FutureBuilder<List<Song>>(
                  future: _fetchSongs(playlist.songIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    }
                    final songs = snapshot.data ?? [];
                    final coverUrls =
                        songs.map((song) => song.coverUrl).take(4).toList();
                    return _buildCoverImages(coverUrls);
                  },
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${playlist.songIds.length} songs',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Playlist",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);

                  _editPlaylist(context, playlist.id, nameController.text);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Playlist",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  await _firebaseService.deletePlaylist(playlist.id);

                  widget.onDelete(playlist.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPlaylist(BuildContext context, String playlistId, String newName) {
    TextEditingController nameController = TextEditingController(text: newName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Edit Playlist Name",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Playlist Name",
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                FocusScope.of(context).unfocus(); // Dismiss the keyboard
                // Update the playlist in Firestore
                await _firebaseService.updatePlaylist(
                  playlistId,
                  nameController.text,
                );
                setState(() {
                  widget.playlist.name =
                      nameController.text; // Update the state
                });
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
