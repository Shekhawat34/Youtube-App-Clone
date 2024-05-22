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

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      title: json['snippet']['title'] as String,
      description: json['snippet']['description'] as String,
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String,
      subscriberCount: (json['statistics']['subscriberCount'] as int?) ?? 0,
      videoCount: (json['statistics']['videoCount'] as int?) ?? 0,
    );
  }
}
