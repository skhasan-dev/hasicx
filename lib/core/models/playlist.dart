class Playlist {
  final int id;
  final String name;
  final String? createdAt;

  Playlist({required this.id, required this.name, this.createdAt});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] ?? json['playlist']?.toString(),
      createdAt: json['createdAt'] ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'createdAt': createdAt};
  }
}
