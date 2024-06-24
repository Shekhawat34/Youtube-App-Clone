class Comment{
  final String id;
  final String authorDisplayName;
  final String authorProfileImageUrl;
  final String textDisplay;
  final DateTime publishedAt;

  Comment({
    required this.id,
    required this.authorDisplayName,
    required this.authorProfileImageUrl,
    required this.textDisplay,
    required this.publishedAt,
});

  factory Comment.fromJson(Map<String,dynamic> json){
    return Comment(
      id: json['id'] as String,
      authorDisplayName: json['snippet']['authorDisplayName'] as String,
      authorProfileImageUrl: json['snippet']['authorProfileImageUrl'] as String,
      textDisplay: json['snippet']['textDisplay'] as String,
      publishedAt: DateTime.parse(json['snippet']['publishedAt'] as String),




    );
  }

}