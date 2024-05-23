import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/screen/videoScreen.dart';
import 'package:youtube_app/screen/searchScreen.dart';
import '../designs/play_button_paint.dart';
import '../model/recommended_video_model.dart';
import '../provider/video_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).fetchRecommendedVideos();
    });
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
                // _buildHorizontalList(),
                // _buildCategoryChips(),
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
            height: 50,
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
      duration: Duration(milliseconds: 300),
      top: _isSearchActive ? 0.0 : 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _isSearchActive ? 1.0 : 0.0,
        child: Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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

  // Widget _buildHorizontalList() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: List.generate(10, (index) {
  //         return const Padding(
  //           padding: EdgeInsets.all(8.0),
  //           child: CircleAvatar(
  //             backgroundImage: AssetImage("assets/images/youtube_logo.jpg"),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }

  // Widget _buildCategoryChips() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: ['All', 'Game', 'UI', 'Figma', 'UI Designer', 'UX', 'Mixes', 'Mobile App']
  //           .map((category) {
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //           child: Chip(
  //             label: Text(category, style: const TextStyle(color: Colors.white)),
  //             backgroundColor: Colors.grey,
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

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
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videoProvider.recommendedVideos.length,
          itemBuilder: (context, index) {
            final recommendedVideo = videoProvider.recommendedVideos[index];
            return _buildVideoCard(context, recommendedVideo);
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
                  size: Size(40, 40),
                  painter: PlayButtonPainter(),
                  child: Center(
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
