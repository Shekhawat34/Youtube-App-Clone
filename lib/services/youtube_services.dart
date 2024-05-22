import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_kets.dart';

class YouTubeApiService {
  static const _apiKey = YOUTUBE_API_KEY;
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<Map<String, dynamic>> fetchVideos(String query) async {
    final url = '$_baseUrl/search?part=snippet&type=video,channel,playlist&maxResults=10&q=$query&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<Map<String, dynamic>> fetchVideosWithPageToken(String query, String pageToken) async {
    final url = '$_baseUrl/search?part=snippet&type=video,channel,playlist&maxResults=10&q=$query&pageToken=$pageToken&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<Map<String, dynamic>> fetchChannel(String channelId) async {
    final url = '$_baseUrl/channels?part=snippet,statistics&id=$channelId&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load channel details');
    }
  }

  Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
    final url = '$_baseUrl/videos?part=snippet,statistics&id=$videoId&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load video details');
    }
  }


  Future<Map<String, dynamic>> fetchRecommendedVideos() async {
    const url = '$_baseUrl/search?part=snippet&type=video,channel,playlist&maxResults=10&regionCode=US&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
