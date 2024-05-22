class RecommendedVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  final String publishedAt;

  RecommendedVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    // required this.viewCount,
    required this.publishedAt,
  });

  factory RecommendedVideo.fromJson(Map<String, dynamic> json) {
    return RecommendedVideo(
      id: json['id']['videoId'] as String,
      title: json['snippet']['title'] as String,
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String,
      channelTitle: json['snippet']['channelTitle'] as String,
      publishedAt: json['snippet']['publishedAt'] as String,
    );
  }
}
