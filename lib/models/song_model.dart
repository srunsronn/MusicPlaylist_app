class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String coverUrl;
  final String songUrl;
  final num? duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.coverUrl,
    required this.songUrl,
    this.duration,
  });

  @override
  String toString() {
    return 'Song{id: $id, songUrl: $songUrl, title: $title, artist: $artist, coverUrl: $coverUrl}';
  }

  factory Song.fromFirestore(Map<String, dynamic> data, String id) {
    return Song(
      id: id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      album: data['album'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      songUrl: data['songUrl'] ?? '',
      duration: data['duration'],
    );
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'],
      coverUrl: map['coverUrl'] ?? '',
      songUrl: map['songUrl'] ?? '',
      duration: map['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'songUrl': songUrl,
      'duration': duration,
    };
  }
}
