import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  bool _isLiked=false;
  bool _isDisliked=false;


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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

            // Initialize like and dislike counts
            _likeCount = int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0;
            _dislikeCount = int.tryParse(statistics['dislikeCount']?.toString() ?? '0')?? 0;

            return SingleChildScrollView(
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
                          progressColors:ProgressBarColors(playedColor: Colors.red,),

                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              ),
                              if (_isExpanded)
                                Column(
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
                                ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon:Icon( _isLiked?Icons.thumb_up:Icons.thumb_up_outlined, color: Colors.white),
                                          onPressed: () {
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
                                        Text(formatNumber(_likeCount), style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined, color: Colors.white),
                                          onPressed: () {
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
                                        Text(formatNumber(_dislikeCount), style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.send_outlined, color: Colors.white,),
                                          onPressed: () {
                                            // Handle share functionality
                                          },
                                        ),
                                        const Text('Share', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                                          onPressed: () {
                                            // Handle download functionality
                                          },
                                        ),
                                        const Text('Download', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                                          onPressed: () {
                                            // Handle save functionality
                                          },
                                        ),
                                        const Text('Save', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Row(
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjust padding as needed
                                      minimumSize: const Size(0, 0), // Remove minimum size constraint
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Remove default button padding
                                    ),
                                    child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
