class Playlist {
  final String id;
   String name;
  final String userId;
  final List<String> songIds;

  Playlist({
    required this.id,
    required this.name,
    required this.userId,
    required this.songIds,
  });
  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, userId: $userId, songIds: $songIds}';
  }

  factory Playlist.fromFirestore(Map<String, dynamic> data, String id) {
    return Playlist(
      id: id,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'songIds': songIds,
    };
  }
}
