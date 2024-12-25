import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.photoURL,
    this.createdAt,
  });

  @override
  String toString() {
    return 'AppUser{uid: $uid, username: $username, email: $email, photoURL: $photoURL, createdAt: $createdAt}';
  }

  /// Factory constructor to create an `AppUser` from Firestore data
  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      username: data['username'] ?? 'Unknown',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create an `AppUser` from a Map
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }

  /// Method to convert an `AppUser` instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}