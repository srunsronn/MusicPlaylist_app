// import 'package:auth_firebase/screens/musicplay/music_player.dart';
// import 'package:flutter/material.dart';

// class SongGrid extends StatelessWidget {
//   const SongGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: List.generate(4, (index) {
//           // Sample song data for UI display
//           final songTitle = 'Song $index';
//           final songUrl = 'url_for_song_$index';

//           return Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: GestureDetector(
//               onTap: () {
//                 // Navigate to MusicPlayer page when a song card is tapped
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MusicPlayer()),
//                 );
//               },
//               child: Container(
//                 width: 173, // Fixed width for each item
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: const Color(0xFF343434),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.asset(
//                           "assets/bg_getstarted.jpg",
//                           height: 152,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         songTitle, // Display dynamic song title
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Text(
//                         "Ronann", // Static artist name, you can make it dynamic too
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
