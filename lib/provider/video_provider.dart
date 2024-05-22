import 'package:flutter/material.dart';
import '../model/channel_model.dart';
import '../model/youtube_model.dart';
import '../model/recommended_video_model.dart';
import '../services/youtube_services.dart';

class VideoProvider with ChangeNotifier {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<Video> _videos = [];
  final List<Channel> _channels = [];
  List<RecommendedVideo> _recommendedVideos = [];
  bool _isLoading = false;
  String _nextPageToken = '';
  String _query = '';

  List<Video> get videos => _videos;
  List<Channel> get channels => _channels;
  List<RecommendedVideo> get recommendedVideos => _recommendedVideos;
  bool get isLoading => _isLoading;

  Future<void> fetchVideos(String query) async {
    _isLoading = true;
    _query = query;
    notifyListeners();
    final data = await _apiService.fetchVideos(query);
    _videos = (data['items'] as List)
        .where((item) => item['id']['kind'] == 'youtube#video')
        .map((json) => Video.fromJson(json))
        .toList();
    _nextPageToken = data['nextPageToken'] ?? '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreVideos() async {
    if (_nextPageToken.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    final data = await _apiService.fetchVideosWithPageToken(_query, _nextPageToken);
    _videos.addAll((data['items'] as List)
        .where((item) => item['id']['kind'] == 'youtube#video')
        .map((json) => Video.fromJson(json))
        .toList());
    _nextPageToken = data['nextPageToken'] ?? '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchChannel(String channelId) async {
    final channelData = await _apiService.fetchChannel(channelId);
    final channel = Channel.fromJson(channelData['items'][0]);
    _channels.add(channel);
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
    final videoDetails = await _apiService.fetchVideoDetails(videoId);
    return videoDetails['items'][0];
  }

  Future<void> fetchRecommendedVideos() async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _apiService.fetchRecommendedVideos();
      if (data['items'] != null && data['items'] is List) {
        _recommendedVideos = (data['items'] as List)
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((json) => RecommendedVideo.fromJson(json))
            .toList();
      } else {
        print("No recommended videos found");
      }
    }catch (e) {
      print("Error fetching recommended videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
