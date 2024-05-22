class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelId;
  final String publishedAt;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']['videoId'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      channelTitle: json['snippet']['channelTitle'],
      channelId: json['snippet']['channelId'],
      publishedAt: json['snippet']['publishedAt'],
      viewCount: json['statistics'] != null ? int.parse(json['statistics']['viewCount'] ?? '0') : 0,
      likeCount: json['statistics']!= null ? int.parse(json['statistics']['likeCount'] ?? '0') : 0,
      dislikeCount: json['statistics']!= null ? int.parse(json['statistics']['dislikeCount'] ?? '0') : 0,
    );
  }
}
