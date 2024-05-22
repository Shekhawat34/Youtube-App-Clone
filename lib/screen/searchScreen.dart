import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import '../provider/video_provider.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Fetch searched videos when the SearchScreen is built
    Provider.of<VideoProvider>(context, listen: false).fetchVideos(query);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Search Results', style: TextStyle(color: Colors.white)),
        ),
        body: Consumer<VideoProvider>(
          builder: (context, videoProvider, child)
          {
            if (videoProvider.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.red));
            }
            if (videoProvider.videos.isEmpty) {
              return const Center(child: Text(
                  'No videos available', style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              itemCount: videoProvider.videos.length,
              itemBuilder: (context, index) {
                final video = videoProvider.videos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoScreen(videoId: video.id),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              placeholder: (context, url) =>
                              const Center(
                                child: CircularProgressIndicator(color: Colors.red),
                              ),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.red),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video.channelTitle,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
    );
  }
}
