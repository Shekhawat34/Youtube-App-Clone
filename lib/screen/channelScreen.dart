import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/video_provider.dart';

class ChannelScreen extends StatelessWidget {
  final String channelId;

  const ChannelScreen({super.key, required this.channelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel Details'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: Provider.of<VideoProvider>(context, listen: false).fetchChannel(channelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading channel',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                final channel = videoProvider.channels.firstWhere((ch) => ch.id == channelId);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: channel.thumbnailUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        channel.title,
                        style: const TextStyle(color: Colors.red, fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        channel.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subscribers: ${channel.subscriberCount}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Videos: ${channel.videoCount}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}