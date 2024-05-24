import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import '../provider/video_provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSection(
                context,
                'Saved Videos',
                videoProvider.savedVideos,
                Icons.bookmark,
                Colors.red,
              ),
              _buildSection(
                context,
                'History',
                videoProvider.history,
                Icons.history,
                Colors.blue,
              ),
              _buildSection(
                context,
                'Watch Later',
                videoProvider.watchLaterVideos,
                Icons.watch_later,
                Colors.orange,
              ),
              _buildSection(
                context,
                'Downloaded Videos',
                videoProvider.downloadedVideos,
                Icons.download,
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Map<String, dynamic>> videos, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: [
          videos.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No $title available',
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          )
              : SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final thumbnailUrl = video['thumbnailUrl'] ?? '';
                final videoTitle = video['title'] ?? 'No title available';
                final videoId = video['id'] ?? '';

                return GestureDetector(
                  onTap: () {
                    if (videoId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoScreen(videoId: videoId),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          videoTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
