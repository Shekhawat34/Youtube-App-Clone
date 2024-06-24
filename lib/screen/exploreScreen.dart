import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import '../model/youtube_model.dart';
import '../provider/video_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All','Trending','Music','Movie', 'Funny', 'Entertainment', 'Sports', 'Shorts', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchExploreVideos();
  }

  void _fetchExploreVideos() {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    videoProvider.fetchExploreVideos(selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    final exploreVideos = videoProvider.exploreVideos;

    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        backgroundColor: Colors.black,
        title: const Text('explore', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: videoProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildVideoList(exploreVideos),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final Map<String, IconData> filterIcons = {
      'All': Icons.all_inclusive,
      'Trending':Icons.local_fire_department_sharp,
      'Music':Icons.music_note_rounded,
      'Movie':Icons.movie_creation_rounded,
      'Funny': Icons.emoji_emotions,
      'Entertainment': Icons.movie,
      'Sports': Icons.sports,
      'Shorts': Icons.video_library,
      'Other': Icons.more_horiz,
    };

    return Container(
      height: 50,
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          final icon = filterIcons[filter];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
              _fetchExploreVideos();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? Colors.red : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    height: 2,
                    width: 30,
                    color: Colors.red,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoList(List<Video> videos) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnailUrl = video.thumbnailUrl ?? '';
        final videoTitle = video.title ?? 'No title available';
        final channel=video.channelTitle??'No channel available';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoScreen(videoId: video.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 220,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      videoTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
