class Channel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int subscriberCount;
  final int videoCount;

  Channel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
  });

  // Factory constructor for creating a new Channel instance from a JSON map.
  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      title: json['snippet']['title'] as String? ?? '',
      description: json['snippet']['description'] as String? ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String? ?? '',
      subscriberCount: int.tryParse(json['statistics']['subscriberCount'] ?? '0') ?? 0,
      videoCount: int.tryParse(json['statistics']['videoCount'] ?? '0') ?? 0,
    );
  }

}
