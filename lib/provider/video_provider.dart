import 'package:flutter/material.dart';
import '../model/channel_model.dart';
import '../model/comment_Model.dart';
import '../model/playlist_model.dart';
import '../model/youtube_model.dart';
import '../model/recommended_video_model.dart';
import '../services/youtube_services.dart';

class VideoProvider with ChangeNotifier {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<Video> _videos = [];
  final List<Channel> _channels = [];
  List<RecommendedVideo> _recommendedVideos = [];
  List<Video> _exploreVideos = [];
  List<Video> _relatedVideos = [];
  List<Playlist> _channelPlaylists = [];
  Map<String, dynamic>? _channelDetails;
  List<Video> _channelVideos = [];
  List<Comment> _videoComments = [];
  List<Comment> _channelComments = [];

  final List<Map<String, dynamic>> _savedVideos = [];
  final List<Map<String, dynamic>> _watchLaterVideos = [];

  final List<Map<String, dynamic>> _downloadedVideos = [];
  final List<Map<String, dynamic>> _history = [];

  bool _isLoading = false;
  String _nextPageToken = '';
  String _query = '';

  List<Video> get videos => _videos;
  List<Channel> get channels => _channels;
  List<Playlist> get channelPlaylists => _channelPlaylists;
  List<RecommendedVideo> get recommendedVideos => _recommendedVideos;
  List<Video> get exploreVideos => _exploreVideos;
  List<Video> get relatedVideos => _relatedVideos;
  List<Video> get channelVideos => _channelVideos;
  List<Comment> get videoComments => _videoComments;
  List<Comment> get channelComments => _channelComments;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get channelDetails => _channelDetails;

  List<Map<String, dynamic>> get savedVideos => _savedVideos;
  List<Map<String, dynamic>> get watchLaterVideos => _watchLaterVideos;
  List<Map<String, dynamic>> get downloadedVideos => _downloadedVideos;
  List<Map<String, dynamic>> get history => _history;

  Future<void> fetchVideos(String query) async {
    _isLoading = true;
    _query = query;
    notifyListeners();
    try {
      final data = await _apiService.fetchVideos(query);
      _videos = (data['items'] as List)
          .where((item) => item['id']['kind'] == 'youtube#video')
          .map((json) => Video.fromJson(json))
          .toList();
      _nextPageToken = data['nextPageToken'] ?? '';
    } catch (e) {
      print("Error fetching videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreVideos() async {
    if (_nextPageToken.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.fetchVideosWithPageToken(_query, _nextPageToken);
      _videos.addAll((data['items'] as List)
          .where((item) => item['id']['kind'] == 'youtube#video')
          .map((json) => Video.fromJson(json))
          .toList());
      _nextPageToken = data['nextPageToken'] ?? '';
    } catch (e) {
      print("Error fetching more videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchChannel(String channelId) async {
  //   try {
  //     final channelData = await _apiService.fetchChannel(channelId);
  //     final channel = Channel.fromJson(channelData['items'][0]);
  //     _channels.add(channel);
  //   } catch (e) {
  //     print("Error fetching channel: $e");
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
    try {
      final videoDetails = await _apiService.fetchVideoDetails(videoId);
      return videoDetails['items'][0];
    } catch (e) {
      print("Error fetching video details: $e");
      rethrow;
    }
  }

  Future<void> fetchRecommendedVideos() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.fetchRecommendedVideos();
      if (data['items'] != null && data['items'] is List) {
        _recommendedVideos = (data['items'] as List)
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((json) => RecommendedVideo.fromJson(json))
            .toList();
      } else {
        print("No recommended videos found");
      }
    } catch (e) {
      print("Error fetching recommended videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExploreVideos(String category) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.fetchExploreVideos(category);
      _exploreVideos = (data['items'] as List)
          .where((item) => item['id']['kind'] == 'youtube#video')
          .map((json) => Video.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching explore videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRelatedVideos(String videoId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final videoDetails = await fetchVideoDetails(videoId);
      final channelId = videoDetails['snippet']['channelId'];
      final data = await _apiService.fetchChannelVideos(channelId);
      _relatedVideos = (data['items'] as List)
          .where((item) => item['id']['kind'] == 'youtube#video')
          .map((json) => Video.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching related videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommentsForVideo(String videoId) async {
    try {
      final comments = await _apiService.fetchCommentsForVideo(videoId);
      _videoComments = comments;
    } catch (e) {
      print("Error fetching comments for video: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchCommentsForChannel(String channelId) async {
    try {
      final comments = await _apiService.fetchCommentsForChannel(channelId);
      _channelComments = comments;
    } catch (e) {
      print("Error fetching comments for channel: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchChannelVideos(String channelId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.fetchChannelVideos(channelId);
      _channelVideos = (data['items'] as List)
          .where((item) => item['id']['kind'] == 'youtube#video')
          .map((json) => Video.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching channel videos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchChannelPlaylists(String channelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _channelPlaylists = await YouTubeApiService.fetchChannelPlaylists(channelId);
    } catch (error) {
      _channelPlaylists = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchChannelDetails(String channelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _channelDetails = await YouTubeApiService.fetchChannelDetails(channelId);
    } catch (error) {
      _channelDetails = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void saveVideo(Map<String, dynamic> video) {
    _savedVideos.add(video);
    notifyListeners();
  }

  void addToWatchLater(Map<String, dynamic> video) {
    _watchLaterVideos.add(video);
    notifyListeners();
  }

  void downloadVideo(Map<String, dynamic> video) {
    _downloadedVideos.add(video);
    notifyListeners();
  }

  void addToHistory(Map<String, dynamic> video) {
    _history.add(video);
    notifyListeners();
  }
}
