import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_app/provider/video_provider.dart';
import 'package:youtube_app/screen/channelScreen.dart';
import 'package:youtube_app/screen/exploreScreen.dart';
import 'package:youtube_app/screen/homeScreen.dart';
import 'package:youtube_app/screen/libraryScreen.dart';
import 'package:youtube_app/screen/videoScreen.dart';

void main() {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
      ],
      child: MaterialApp(
        title: 'YouTube Clone',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        routes: {
          '/channel': (context) => ChannelScreen(
            channelId: ModalRoute.of(context)!.settings.arguments as String,
          ),
          '/video': (context) => VideoScreen(
            videoId: ModalRoute.of(context)!.settings.arguments as String,
          ),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    const ExploreScreen(),
    // Placeholder for the ChannelScreen since channelId is required
    const Scaffold(
      body: Center(
        child: Text('Channel Screen Placeholder', style: TextStyle(color: Colors.white)),
      ),
    ),
    const LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          print('floating action button pressed');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
