import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_kets.dart';
import '../model/comment_Model.dart';
import '../model/playlist_model.dart';

class YouTubeApiService {
  static const String _apiKey = YOUTUBE_API_KEY;
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<Map<String, dynamic>> _getRequest(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  String _constructUrl(String endpoint, Map<String, String> parameters) {
    final params = parameters.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_baseUrl/$endpoint?$params&key=$_apiKey';
  }

  Future<Map<String, dynamic>> fetchVideos(String query) async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video,channel,playlist',
      'maxResults': '10',
      'q': query,
    });
    return await _getRequest(url);
  }

  Future<Map<String, dynamic>> fetchVideosWithPageToken(String query, String pageToken) async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video,channel,playlist',
      'maxResults': '50',
      'q': query,
      'pageToken': pageToken,
    });
    return await _getRequest(url);
  }

  Future<Map<String, dynamic>> fetchChannelVideos(String channelId) async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video',
      'maxResults': '50',
      'channelId': channelId,
      'order':'date'
    });
    return await _getRequest(url);
  }


  Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
    final url = _constructUrl('videos', {
      'part': 'snippet,statistics',
      'id': videoId,
    });
    return await _getRequest(url);
  }
  static Future<List<Playlist>> fetchChannelPlaylists(String channelId) async {
    final url = '$_baseUrl/playlists?key=$_apiKey&channelId=$channelId&part=snippet&maxResults=20';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List playlists = data['items'];
      return playlists.map((playlist) => Playlist.fromJson(playlist)).toList();
    } else {
      throw Exception('Failed to load channel playlists');
    }
  }
  static Future<Map<String, dynamic>> fetchChannelDetails(String channelId) async {
    final url = '$_baseUrl/channels?key=$_apiKey&id=$channelId&part=snippet,statistics';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final channel = data['items'][0];
      return {
        'title': channel['snippet']['title'],
        'description': channel['snippet']['description'],
        'subscriberCount': channel['statistics']['subscriberCount'],
        'videoCount': channel['statistics']['videoCount'],
        'thumbnailUrl': channel['snippet']['thumbnails']['high']['url'],
      };
    } else {
      throw Exception('Failed to load channel details');
    }
  }

  Future<Map<String, dynamic>> fetchRecommendedVideos() async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video,channel,playlist',
      'maxResults': '50',
      'regionCode': 'IN',
    });
    return await _getRequest(url);
  }

  Future<Map<String, dynamic>> fetchExploreVideos(String category) async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video',
      'maxResults': '50',
      'q': category,
    });
    return await _getRequest(url);
  }

  Future<Map<String, dynamic>> fetchRelatedVideos(String videoId) async {
    // Fetch the video details to get the channel ID
    final videoDetails = await fetchVideoDetails(videoId);
    final channelId = videoDetails['items'][0]['snippet']['channelId'];

    // Fetch videos from the same channel
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video',
      'maxResults': '10',
      'channelId': channelId,
    });
    return await _getRequest(url);
  }

  Future<List<Comment>> fetchCommentsForVideo(String videoId) async {
    final url = _constructUrl('commentThreads', {
      'part': 'snippet',
      'videoId': videoId,
      'maxResults': '10',
    });
    final response = await _getRequest(url);
    final List<dynamic> items = response['items'] ?? [];
    return items.map((item) => Comment.fromJson(item['snippet']['topLevelComment'])).toList();
  }

  Future<List<Comment>> fetchCommentsForChannel(String channelId) async {
    final url = _constructUrl('commentThreads', {
      'part': 'snippet',
      'channelId': channelId,
      'maxResults': '10',
    });
    final response = await _getRequest(url);
    final List<dynamic> items = response['items'] ?? [];
    return items.map((item) => Comment.fromJson(item['snippet']['topLevelComment'])).toList();
  }
}
