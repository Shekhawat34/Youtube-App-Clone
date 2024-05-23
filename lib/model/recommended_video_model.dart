class RecommendedVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  // final int viewCount;

  RecommendedVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    // required this.viewCount,
  });

  factory RecommendedVideo.fromJson(Map<String, dynamic> json) {
    return RecommendedVideo(
      id: json['id']['videoId'] as String,
      title: json['snippet']['title'] as String,
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String,
      channelTitle: json['snippet']['channelTitle'] as String,
      publishedAt: DateTime.parse(json['snippet']['publishedAt'] as String),
      // viewCount: json['statistics'] != null ? int.tryParse(json['statistics']['viewCount'] ?? '0') ?? 0 : 0,
    );
  }
}
