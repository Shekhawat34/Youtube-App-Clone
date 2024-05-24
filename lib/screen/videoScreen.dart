import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../designs/play_button_paint.dart';
import '../model/recommended_video_model.dart';
import '../provider/video_provider.dart';

class VideoScreen extends StatefulWidget {
  final String videoId;

  const VideoScreen({super.key, required this.videoId});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;
  late Future<Map<String, dynamic>> _videoDetailsFuture;
  int _likeCount = 0;
  int _dislikeCount = 0;
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
      ),
    );
    _videoDetailsFuture = Provider.of<VideoProvider>(context, listen: false).fetchVideoDetails(widget.videoId);

    _controller.addListener(_onPlayerStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).fetchRecommendedVideos();
    });

     // add video to history
    _videoDetailsFuture.then((video) {
      Provider.of<VideoProvider>(context, listen: false).addToHistory(video);
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _videoDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading video details', style: TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available', style: TextStyle(color: Colors.red)),
            );
          } else {
            final videoDetails = snapshot.data!;
            final snippet = videoDetails['snippet'] ?? {};
            final statistics = videoDetails['statistics'] ?? {};

            _likeCount = int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0;
            _dislikeCount = int.tryParse(statistics['dislikeCount']?.toString() ?? '0') ?? 0;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        color: Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            YoutubePlayer(
                              controller: _controller,
                              showVideoProgressIndicator: true,
                              onReady: () {
                                _controller.addListener(() {});
                              },
                              progressIndicatorColor: Colors.red,
                              progressColors: const ProgressBarColors(
                                playedColor: Colors.red,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTitleSection(snippet),
                                  if (_isExpanded) _buildExpandedSection(snippet, statistics),
                                  const SizedBox(height: 4),
                                  _buildInteractionRow(),
                                  const SizedBox(height: 8),
                                  _buildSubscribeSection(),
                                  const SizedBox(height: 16,),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildRecommendedVideosSection(),
                    ],
                  ),

                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                  Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                  if (value == 'save') {
                  Provider.of<VideoProvider>(context, listen: false).saveVideo(videoDetails);
                  }
                  },
                  itemBuilder: (BuildContext context) {
                  return [
                  const PopupMenuItem(
                  value: 'save',
                  child: Text('Save Video'),
                  ),
                  ];
                  },

                   ),
          ),
          ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTitleSection(Map<String, dynamic> snippet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            snippet['title'] ?? 'No title available',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildExpandedSection(Map<String, dynamic> snippet, Map<String, dynamic> statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          snippet['description'] ?? 'No description available',
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
        ),
        const SizedBox(height: 8),
        Text(
          'Published on: ${snippet['publishedAt'] ?? 'N/A'}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Views: ${statistics['viewCount']?.toString() ?? 'N/A'}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInteractionButton(
          icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: formatNumber(_likeCount),
          isActive: _isLiked,
          onTap: () {
            setState(() {
              if (_isLiked) {
                _likeCount--;
                _isLiked = false;
              } else {
                _likeCount++;
                if (_isDisliked) {
                  _dislikeCount--;
                  _isDisliked = false;
                }
                _isLiked = true;
              }
            });
          },
        ),
        _buildInteractionButton(
          icon: _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          label: formatNumber(_dislikeCount),
          isActive: _isDisliked,
          onTap: () {
            setState(() {
              if (_isDisliked) {
                _dislikeCount--;
                _isDisliked = false;
              } else {
                _dislikeCount++;
                if (_isLiked) {
                  _likeCount--;
                  _isLiked = false;
                }
                _isDisliked = true;
              }
            });
          },
        ),
        _buildInteractionButton(
          icon: Icons.send_outlined,
          label: 'Share',
          onTap: () {
            // Handle share functionality
          },
        ),
        _buildInteractionButton(
          icon: Icons.file_download_outlined,
          label: 'Download',
          onTap: () {
            // Handle download functionality
          },
        ),
        _buildInteractionButton(
          icon: Icons.save_as_outlined,
          label: 'Save',
          onTap: () {
            // Handle save functionality
          },
        ),
      ],
    );
  }

  Widget _buildInteractionButton({required IconData icon, required String label, bool isActive = false, required VoidCallback onTap}) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, color: isActive ? Colors.blue : Colors.white),
            onPressed: onTap,
          ),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSubscribeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Handle bell icon functionality
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Handle subscribe functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildRecommendedVideosSection() {
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
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1200) {
              // Larger screens: 5 videos per row
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.75,
                ),
                itemCount: videoProvider.recommendedVideos.length,
                itemBuilder: (context, index) {
                  final recommendedVideo = videoProvider.recommendedVideos[index];
                  return _buildVideoCard(context, recommendedVideo);
                },
              );
            } else if (constraints.maxWidth > 768) {
              // Tablets: 4 videos per row
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                ),
                itemCount: videoProvider.recommendedVideos.length,
                itemBuilder: (context, index) {
                  final recommendedVideo = videoProvider.recommendedVideos[index];
                  return _buildVideoCard(context, recommendedVideo);
                },
              );
            } else if (constraints.maxWidth > 480 && constraints.maxWidth <= 768) {
              // Small tablets: 3 videos per row
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                ),
                itemCount: videoProvider.recommendedVideos.length,
                itemBuilder: (context, index) {
                  final recommendedVideo = videoProvider.recommendedVideos[index];
                  return _buildVideoCard(context, recommendedVideo);
                },
              );
            } else {
              // Mobile: 1 video per row
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videoProvider.recommendedVideos.length,
                itemBuilder: (context, index) {
                  final recommendedVideo = videoProvider.recommendedVideos[index];
                  return _buildVideoCard(context, recommendedVideo);
                },
              );
            }
          },
        );
      },
    );
  }


  Widget _buildVideoCard(BuildContext context, RecommendedVideo recommendedVideo) {
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
                    imageUrl: recommendedVideo.thumbnailUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendedVideo.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recommendedVideo.channelTitle,
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
