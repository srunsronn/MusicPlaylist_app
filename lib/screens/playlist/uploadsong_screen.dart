// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// class UploadSongScreen extends StatefulWidget {
//   @override
//   _UploadSongScreenState createState() => _UploadSongScreenState();
// }

// class _UploadSongScreenState extends State<UploadSongScreen> {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   String? _songFileName;
//   String? _coverFileName;
//   // String? _songDownloadUrl;
//   String? _coverDownloadUrl;

//   // Function to pick and upload the song (MP3 file)
//   Future<void> pickAndUploadSong() async {
//     // Pick the song (MP3 file)
//     FilePickerResult? songResult =
//         await FilePicker.platform.pickFiles(type: FileType.audio);
//     if (songResult == null) return; // Exit if no song file was selected

//     // Get file reference
//     var songFile = songResult.files.single;

//     // Define Firebase storage path for the song
//     String songPath = 'songs/${songFile.name}';

//     try {
//       // Upload the song to Firebase Storage
//       TaskSnapshot songUpload =
//           await _storage.ref(songPath).putData(songFile.bytes!);
//       _songDownloadUrl = await songUpload.ref.getDownloadURL();

//       setState(() {
//         _songFileName = songFile.name;
//       });

//       // You can now use this download URL to play the song or store it
//       print("Song URL: $_songDownloadUrl");
//     } catch (e) {
//       print("Error uploading song: $e");
//     }
//   }

//   // Function to pick and upload the cover image
//   Future<void> pickAndUploadCover() async {
//     // Pick the cover image (Image file)
//     FilePickerResult? coverResult =
//         await FilePicker.platform.pickFiles(type: FileType.image);
//     if (coverResult == null) return; // Exit if no cover image was selected

//     // Get file reference
//     var coverFile = coverResult.files.single;

//     // Define Firebase storage path for the cover image
//     String coverPath = 'covers/${coverFile.name}';

//     try {
//       // Upload the cover image to Firebase Storage
//       TaskSnapshot coverUpload =
//           await _storage.ref(coverPath).putData(coverFile.bytes!);
//       _coverDownloadUrl = await coverUpload.ref.getDownloadURL();

//       setState(() {
//         _coverFileName = coverFile.name;
//       });

//       // You can now use this download URL to show the cover image
//       print("Cover Image URL: $_coverDownloadUrl");
//     } catch (e) {
//       print("Error uploading cover image: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Song")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Button to pick and upload the song (MP3)
//             ElevatedButton(
//               onPressed: pickAndUploadSong,
//               child: const Text("Pick and Upload Song (MP3)"),
//             ),
//             if (_songFileName != null) Text("Song: $_songFileName"),
//             if (_songDownloadUrl != null)
//               ElevatedButton(
//                 onPressed: () {
//                   print("Playing song from URL: $_songDownloadUrl");
//                   // You can integrate your audio player here to play the song
//                 },
//                 child: const Text("Play Song"),
//               ),

//             const SizedBox(height: 20),

//             // Button to pick and upload the cover image
//             ElevatedButton(
//               onPressed: pickAndUploadCover,
//               child: const Text("Pick and Upload Cover Image"),
//             ),
//             if (_coverFileName != null) Text("Cover: $_coverFileName"),
//           ],
//         ),
//       ),
//     );
//   }
// }
