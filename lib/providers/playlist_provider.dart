// import 'package:flutter/material.dart';

// class PlaylistProvider with ChangeNotifier {
//   List<String> _playlists = [];

//   List<String> get playlists => _playlists;

//   void addPlaylist(String playlistName) {
//     _playlists.add(playlistName);
//     notifyListeners();
//   }

//   void removePlaylist(String playlistName) {
//     _playlists.remove(playlistName);
//     notifyListeners();
//   }

//   void updatePlaylist(int index, String newName) {
//     if (index >= 0 && index < _playlists.length) {
//       _playlists[index] = newName;
//       notifyListeners();
//     }
//   }
// }

// class PlaylistProviderWidget extends StatelessWidget {
//   const PlaylistProviderWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => PlaylistProvider(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Playlists'),
//         ),
//         body: const PlaylistScreen(),
//       ),
//     );
//   }
// }

// class PlaylistScreen extends StatelessWidget {
//   const PlaylistScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final playlistProvider = Provider.of<PlaylistProvider>(context);

//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: playlistProvider.playlists.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(playlistProvider.playlists[index]),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () {
//                     playlistProvider.removePlaylist(
//                         playlistProvider.playlists[index]);
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             decoration: const InputDecoration(
//               labelText: 'Add Playlist',
//               border: OutlineInputBorder(),
//             ),
//             onSubmitted: (value) {
//               if (value.isNotEmpty) {
//                 playlistProvider.addPlaylist(value);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
