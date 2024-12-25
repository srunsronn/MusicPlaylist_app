//import
import 'dart:io';
import 'package:auth_firebase/models/playlist_model.dart';
import 'package:auth_firebase/models/song_model.dart';
import 'package:auth_firebase/models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(
      String username, String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': '', // Default value or handle as needed
        });

        // Return the custom AppUser object
        return AppUser(
          uid: user.uid,
          username: username,
          email: email,
          photoURL: '', // Set accordingly
          createdAt: DateTime.now(),
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      String errorMessage = 'Error signing up';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      print('Error: $errorMessage');
      return null;
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        return AppUser.fromFirestore(
            userDoc.data() as Map<String, dynamic>, user.uid);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      print('Error: ${e.message}');
      return null;
    }
  }

  // Google sign-in
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('No user is signed in.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'username': googleUser.displayName ?? 'User',
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        return AppUser.fromFirestore(
            userDoc.data() as Map<String, dynamic>, user.uid);
      }

      return null;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  Future<void> addSong(Map<String, dynamic> songData) async {
    await _firestore.collection('songs').add(songData);
  }

  Stream<List<Map<String, dynamic>>> fetchSongs() {
    return _firestore.collection('songs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> addPlaylist(Map<String, dynamic> playlistData) async {
    await _firestore.collection('playlists').add(playlistData);
  }

  // Fetch a list of albums
  Future<List<Map<String, dynamic>>> fetchAlbums() async {
    try {
      // print('Fetching albums...');
      // Fetch album data from Firestore
      QuerySnapshot albumSnapshot = await _firestore.collection('albums').get();
      // print('Albums fetched: ${albumSnapshot.docs.length}');

      // Map documents to album data
      return albumSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Ensure that we handle missing fields gracefully
        return {
          'albumId': doc.id, // Use document ID for album ID
          'name': data['name'] ?? 'Unknown Album Name', // Default if missing
          'artist': data['artist'] ?? 'Unknown Artist',
          'artistUrl': data['artistUrl'] ?? '', // Default if missing
          'coverUrl': data['coverUrl'] ?? '', // Default if missing
          'songIds': List<String>.from(
              data['songIds'] ?? []), // Ensure songIds is a list of strings
        };
      }).toList();
    } catch (e) {
      // Handle error
      print('Error fetching albums: $e');
      return []; // Return empty list in case of error
    }
  }

  // Fetch a list of artists from albums
  Future<List<Map<String, dynamic>>> fetchArtists() async {
    try {
      // print('Fetching artists...');
      // Fetch album data from Firestore
      QuerySnapshot albumSnapshot = await _firestore.collection('albums').get();
      print('Albums fetched: ${albumSnapshot.docs.length}');

      // Extract unique artists from album data
      final artists = albumSnapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['artist'] ?? 'Unknown Artist',
              'imageUrl': data['artistUrl'] ??
                  'https://default-url.com/default-image.jpg',
            };
          })
          .toSet()
          .toList(); // Use a set to ensure uniqueness

      return artists;
    } catch (e) {
      // Handle error
      print('Error fetching artists: $e');
      return []; // Return empty list in case of error
    }
  }

  // Fetch songs for a specific album by album ID
  Future<List<Song>> fetchAlbumSongs(String albumId) async {
    try {
      // Fetch the album document by albumId
      DocumentSnapshot albumSnapshot =
          await _firestore.collection('albums').doc(albumId).get();

      // If no album found, return an empty list
      if (!albumSnapshot.exists) {
        print('Album not found');
        return [];
      }

      // Get the list of songIds from the album document
      List<dynamic> songIds = albumSnapshot['songIds'] ?? [];

      // If no songIds found, return an empty list
      if (songIds.isEmpty) {
        print('No songs found for this album');
        return [];
      }

      // Fetch the songs corresponding to the songIds
      QuerySnapshot songsSnapshot = await _firestore
          .collection('songs')
          .where(FieldPath.documentId, whereIn: songIds)
          .get();

      // Map songs data
      return songsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Song.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching album songs: $e');
      return [];
    }
  }

  // Fetch songs by their IDs
  Future<List<Song>> fetchSongsByIds(List<String> songIds) async {
    try {
      if (songIds.isEmpty) {
        return [];
      }

      // Ensure all songIds are non-null and non-empty
      songIds = songIds.where((id) => id.isNotEmpty).toList();

      if (songIds.isEmpty) {
        return [];
      }

      QuerySnapshot songsSnapshot = await _firestore
          .collection('songs')
          .where(FieldPath.documentId, whereIn: songIds)
          .get();

      return songsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Song.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching songs by IDs: $e');
      return [];
    }
  }

  // Fetch songs by artist ID
  Future<List<Song>> fetchSongsByArtist(String artistId) async {
    try {
      QuerySnapshot songsSnapshot = await _firestore
          .collection('songs')
          .where('artistId', isEqualTo: artistId)
          .get();

      return songsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Song.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching songs by artist: $e');
      return [];
    }
  }

  // Store the last played song in Firestore
  Future<void> setLastPlayedSong(String songId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastPlayedSong': songId, // Store the song ID of the last played song
        });
      }
    } catch (e) {
      print('Error saving last played song: $e');
    }
  }

  Future<String?> getLastPlayedSong() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // Safely cast data to Map<String, dynamic>
          final data = userDoc.data() as Map<String, dynamic>?;

          // Check if the data is not null and contains the key 'lastPlayedSong'
          if (data != null && data.containsKey('lastPlayedSong')) {
            return data[
                'lastPlayedSong']; // Return the song ID of the last played song
          } else {
            print('lastPlayedSong field does not exist.');
            return null; // Return null if the field doesn't exist
          }
        }
      }
    } catch (e) {
      print('Error fetching last played song: $e');
    }
    return null;
  }

  Future<Playlist?> createPlaylist(String name) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final docRef = _firestore.collection('playlists').doc();
        final playlist = Playlist(
          id: docRef.id,
          name: name,
          userId: user.uid,
          songIds: [],
        );
        await docRef.set(playlist.toMap());
        print('Playlist created successfully');
        return playlist; // Return the created playlist
      } else {
        print('No user is currently logged in.');
      }
    } catch (e) {
      print('Error creating playlist: $e');
    }
    return null; // Return null in case of error or no user
  }

  // Fetch playlists for the current user
  Future<List<Playlist>> fetchPlaylists() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('playlists')
            .where('userId', isEqualTo: user.uid)
            .get();
        return querySnapshot.docs
            .map((doc) => Playlist.fromFirestore(doc.data(), doc.id))
            .toList();
      } else {
        print('No user is currently logged in.');
        return [];
      }
    } catch (e) {
      print('Error fetching playlists: $e');
      return [];
    }
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final docRef = _firestore.collection('playlists').doc(playlistId);
      final doc = await docRef.get();
      if (doc.exists) {
        final playlist = Playlist.fromFirestore(doc.data()!, doc.id);
        if (!playlist.songIds.contains(songId)) {
          playlist.songIds.add(songId);
          await docRef.update({
            'songIds': FieldValue.arrayUnion([songId])
          });
          print('Song added to playlist successfully');
        } else {
          print('Song already exists in the playlist');
        }
      } else {
        print('Playlist not found');
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _firestore.collection('playlists').doc(playlistId).delete();
      print('Playlist deleted successfully');
    } catch (e) {
      print('Error deleting playlist: $e');
    }
  }

  Future<void> updatePlaylist(String playlistId, String newName) async {
    try {
      final docRef = _firestore.collection('playlists').doc(playlistId);
      await docRef.update({
        'name': newName,
      });
      print('Playlist updated successfully');
    } catch (e) {
      print('Error updating playlist: $e');
    }
  }
}
