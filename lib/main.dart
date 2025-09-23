import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skd/splash_screen.dart';
import 'dart:convert';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Add this import

import 'HomeScreen.dart';
import 'Search_Movies_Screen.dart';
import 'Recommendation_Movies_Screen.dart';

// --- API Key ---
const String kApiKey = 'Pasted_Your_own_API_of_The_Movie_Database'; // due to github security i can't upload

// --- Reusable API Functions ---
Future<String?> fetchTrailer(int movieId, String apiKey) async {
  final uri = Uri.https(
    'api.themoviedb.org',
    '/3/movie/$movieId/videos',
    {'api_key': apiKey},
  );

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['results'] as List;
      final trailer = videos.firstWhere(
            (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => videos.firstWhere(
              (v) => v['type'] == 'Teaser' && v['site'] == 'YouTube',
          orElse: () => videos.firstWhere(
                (v) => v['site'] == 'YouTube',
            orElse: () => null,
          ),
        ),
      );
      return trailer?['key'];
    }
    print('Failed to fetch trailer for $movieId (status ${response.statusCode})');
    return null;
  } catch (e) {
    print('Error fetching trailer for $movieId: $e');
    return null;
  }
}

void playTrailer(BuildContext context, String videoId) {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
  ]);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * (9 / 16),
              child: YoutubePlayerIFrame(
                controller: YoutubePlayerController(
                  initialVideoId: videoId,
                  params: YoutubePlayerParams(
                    showControls: true,
                    showFullscreenButton: true,
                    autoPlay: true,
                    mute: false,
                    strictRelatedVideos: true,
                  ),
                ),
                aspectRatio: 16 / 9,
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).pop();
                SystemChrome.setPreferredOrientations(DeviceOrientation.values);
              },
              padding: EdgeInsets.all(8.0),
              color: Colors.black54,
              iconSize: 28.0,
              alignment: Alignment.topRight,
            ),
          ),
        ],
      ),
    ),
  );
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Recommender',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white70,
          iconColor: Colors.white70,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),  // <— show splash first
      routes: {
        '/main': (_) => MainScreen(),
      },
    );
  }
}

// --- Main Screen with Curved Navigation & PageView ---
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _screens = [
      HomeScreen(apiKey: kApiKey),
      SearchScreen(apiKey: kApiKey),
      RecommendationScreen(apiKey: kApiKey),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (mounted) setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.purple),
          Icon(Icons.search, size: 30, color: Colors.purple),
          Icon(Icons.recommend_outlined, size: 30, color: Colors.purple),
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.black,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
    );
  }
}
