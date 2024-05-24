import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_kets.dart';

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

  Future<Map<String, dynamic>> fetchChannel(String channelId) async {
    final url = _constructUrl('channels', {
      'part': 'snippet,statistics',
      'id': channelId,
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

  Future<Map<String, dynamic>> fetchRecommendedVideos() async {
    final url = _constructUrl('search', {
      'part': 'snippet',
      'type': 'video,channel,playlist',
      'maxResults': '50',
      'regionCode': 'US',
    });
    return await _getRequest(url);
  }
}
