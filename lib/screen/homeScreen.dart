import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import 'package:youtube_app/screen/searchScreen.dart';
import '../provider/video_provider.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch recommended videos when the HomeScreen is built
    Provider.of<VideoProvider>(context, listen: false).fetchRecommendedVideos();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'assets/images/youtube_logo.jpg',
              height: 34,
            ),
            const Spacer(),
            const Icon(Icons.cast, color: Colors.white70),
            const SizedBox(width: 16),
            const Icon(Icons.notifications, color: Colors.white70),
            const SizedBox(width: 16),
            const CircleAvatar(
              backgroundImage: AssetImage("assets/images/youtube_logo.jpg"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search videos',
                  hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.red),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // Hide the keyboard
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(query: _searchController.text),
                        ),
                      );
                    },
                  ),
                ),
                onSubmitted: (query) {
                  FocusScope.of(context).unfocus(); // Hide the keyboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(query: query),
                    ),
                  );
                },
              ),
            ),
            _buildHorizontalList(context),
            _buildCategoryChips(),
            FutureBuilder(
              future: Provider.of<VideoProvider>(context, listen: false).fetchRecommendedVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                } else {
                  return _buildRecommendedVideos(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/youtube_logo.jpg"),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Game', 'UI', 'Figma', 'UI Designer', 'UX', 'Mixes', 'Mobile App']
            .map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(category, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.grey,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendedVideos(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }
        if (videoProvider.recommendedVideos.isEmpty) {
          return const Center(
            child: Text(
              'No recommended videos available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videoProvider.recommendedVideos.length,
          itemBuilder: (context, index) {
            final recommendedVideo = videoProvider.recommendedVideos[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoScreen(videoId: recommendedVideo.id),
                  ),
                );
              },
              child: Card(
                color: Colors.black,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: recommendedVideo.thumbnailUrl,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendedVideo.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendedVideo.channelTitle,
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
    );
  }
}
