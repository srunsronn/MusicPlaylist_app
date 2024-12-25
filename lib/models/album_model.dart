class Album {
  final String id;
  final String name;
  final String artist;
  final String artistUrl;
  final String coverUrl;
  final List<String> songIds;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.artistUrl,
    required this.coverUrl,
    required this.songIds,
  });

  factory Album.fromFirestore(Map<String, dynamic> data, String id) {
    return Album(
      id: id,
      name: data['name'] ?? 'Unknown Album Name',
      artist: data['artist'] ?? 'Unknown Artist',
      artistUrl: data['artistUrl'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artist': artist,
      'artistUrl': artistUrl,
      'coverUrl': coverUrl,
      'songIds': songIds,
    };
  }
}