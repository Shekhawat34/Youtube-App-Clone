import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:youtube_app/screen/videoScreen.dart';
import 'package:youtube_app/screen/searchScreen.dart';
import '../designs/play_button_paint.dart';
import '../model/recommended_video_model.dart';
import '../provider/video_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitializing = false;
  String _voiceInput = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).fetchRecommendedVideos();
    });
  }

  Future<void> _listen() async {
    if (!_isInitializing && !_isListening) {
      _isInitializing = true;
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );
      _isInitializing = false;

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceInput = val.recognizedWords;
            _searchController.text = _voiceInput;
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildRecommendedVideos(),
              ],
            ),
          ),
          if (_isSearchActive) _buildSearchField(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: _isSearchActive
          ? null
          : Row(
        children: [
          Image.asset(
            'assets/images/youtube_logo.jpg',
            height: 34,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchActive = true;
              });
            },
            child: const Icon(Icons.search, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _listen,
            child: const Icon(Icons.mic, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.cast, color: Colors.white70),
          const SizedBox(width: 10),
          const Icon(Icons.notifications, color: Colors.white70),
        ],
      ),
      actions: _isSearchActive
          ? [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearchActive = false;
              _searchController.clear();
            });
          },
        )
      ]
          : [],
    );
  }

  Widget _buildSearchField() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _isSearchActive ? 6.0 : 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isSearchActive ? 1.0 : 0.0,
        child: Container(
          color: Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onSubmitted: (query) => _onSearchSubmitted(context, query),
          ),
        ),
      ),
    );
  }

  void _onSearchSubmitted(BuildContext context, String query) {
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus(); // Hide the keyboard
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(query: query),
        ),
      );
    }
  }

  Widget _buildRecommendedVideos() {
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
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

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
                    height: isLargeScreen ? 300 : isTablet ? 250 : 220,
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
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recommendedVideo.channelTitle,
                          style: const TextStyle(color: Colors.red),
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
