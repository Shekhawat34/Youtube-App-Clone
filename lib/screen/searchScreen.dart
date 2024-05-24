import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import '../designs/play_button_paint.dart';
import '../model/youtube_model.dart';
import '../provider/video_provider.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    Provider.of<VideoProvider>(context, listen: false).fetchVideos(query);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Search Results', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          if (videoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          if (videoProvider.videos.isEmpty) {
            return const Center(
              child: Text('No videos available', style: TextStyle(color: Colors.white)),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1200) {
                // Larger screens: 5 videos per row
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  itemCount: videoProvider.videos.length,
                  itemBuilder: (context, index) {
                    final video = videoProvider.videos[index];
                    return _buildVideoCard(context, video);
                  },
                );
              } else if (constraints.maxWidth > 768) {
                // Tablets: 4 videos per row
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  itemCount: videoProvider.videos.length,
                  itemBuilder: (context, index) {
                    final video = videoProvider.videos[index];
                    return _buildVideoCard(context, video);
                  },
                );
              } else if (constraints.maxWidth > 480) {
                // Small tablets: 3 videos per row
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  itemCount: videoProvider.videos.length,
                  itemBuilder: (context, index) {
                    final video = videoProvider.videos[index];
                    return _buildVideoCard(context, video);
                  },
                );
              } else {
                // Mobile: 1 video per row
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: videoProvider.videos.length,
                  itemBuilder: (context, index) {
                    final video = videoProvider.videos[index];
                    return _buildVideoCard(context, video);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

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
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    width: double.infinity,
                    height: isLargeScreen ? 200 : isTablet ? 150 : 180,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          video.channelTitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 5,
                right: 10,
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: PlayButtonPainter(),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.red,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
