import 'comment_Model.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelId;
  final DateTime publishedAt;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final List<Comment> comments;

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
    required this.comments,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']['videoId'] as String,
      title: json['snippet']['title'] as String,
      description: json['snippet']['description'] as String,
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String,
      channelTitle: json['snippet']['channelTitle'] as String,
      channelId: json['snippet']['channelId'] as String,
      publishedAt: DateTime.parse(json['snippet']['publishedAt'] as String),
      viewCount: json['statistics'] != null ? int.tryParse(json['statistics']['viewCount'] ?? '0') ?? 0 : 0,
      likeCount: json['statistics'] != null ? int.tryParse(json['statistics']['likeCount'] ?? '0') ?? 0 : 0,
      dislikeCount: json['statistics'] != null ? int.tryParse(json['statistics']['dislikeCount'] ?? '0') ?? 0 : 0,
      comments: [] //Initialize comment list
    );
  }
}
