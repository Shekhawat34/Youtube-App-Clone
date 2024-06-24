import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/video_provider.dart';
import '../model/youtube_model.dart';
import 'videoScreen.dart';

class ChannelScreen extends StatefulWidget {
  final String channelId;

  const ChannelScreen({super.key, required this.channelId});

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> with SingleTickerProviderStateMixin {
  late Future<void> _channelVideosFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _channelVideosFuture = _fetchChannelVideos();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _fetchChannelVideos() async {
    await Provider.of<VideoProvider>(context, listen: false).fetchChannelVideos(widget.channelId);
    await Provider.of<VideoProvider>(context, listen: false).fetchChannelDetails(widget.channelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Videos'),
            Tab(text: 'Playlists'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: FutureBuilder<void>(
        future: _channelVideosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading channel', style: TextStyle(color: Colors.red)));
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildVideosTab(),
                _buildPlaylistsTab(),
                _buildDetailsTab(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildVideosTab() {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.channelVideos.isEmpty) {
          return const Center(child: Text('No videos found for this channel', style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: videoProvider.channelVideos.length,
            itemBuilder: (context, index) {
              Video video = videoProvider.channelVideos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VideoScreen(videoId: video.id)),
                  );
                },
                child: Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video.channelTitle,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }


  Widget _buildPlaylistsTab() {
    // Placeholder for playlists tab content. You'll need to implement fetching playlists from the API.
    return const Center(child: Text('Playlists tab content', style: TextStyle(color: Colors.white)));
  }

  Widget _buildDetailsTab() {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.channelDetails == null) {
          return const Center(child: Text('No details found for this channel', style: TextStyle(color: Colors.white)));
        } else {
          final details = videoProvider.channelDetails!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details['title'] ?? 'No title available',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  details['description'] ?? 'No description available',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Subscribers: ${details['subscriberCount']}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 16),
                    Text('Videos: ${details['videoCount']}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: details['thumbnailUrl'],
                      placeholder: (context, url) => const CircularProgressIndicator(color: Colors.red),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
