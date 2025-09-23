import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'Movie_Detial_And_Play_Screen.dart';
import 'Recommendation_Movies_Screen.dart';
import 'main.dart';

// Assuming kApiKey, fetchTrailer(movieId, apiKey), and playTrailer(context, videoId)
// functions are defined globally or in an accessible service file.
// Also assuming Movie, SearchMovieItem, RecommendedMovieItem, RecommendedMovieItem
// and _RecommendedMovieDisplayItem classes are defined.


// --- 01) Home Screen (Refactored and Enhanced) ---
class HomeScreen extends StatefulWidget {
  final String apiKey;
  const HomeScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Futures for different movie categories
  Future<List<Movie>>? trendingMovies;
  Future<List<Movie>>? nowPlayingMovies;
  Future<List<Movie>>? popularMovies;
  Future<List<Movie>>? topRatedMovies; // New: Top Rated
  Future<List<Movie>>? upcomingMovies; // New: Upcoming
  Future<List<Movie>>? actionMovies;   // New: Action Genre
  Future<List<Movie>>? horrorMovies;   // New: Horror Genre
  Future<List<Movie>>? familyMovies;   // New: Family Genre
  Future<List<Movie>>? comedyMovies;
  Future<List<Movie>>? spaceMovies;


  @override
  void initState() {
    super.initState();
    // Fetch diverse categories using the API key
    trendingMovies = fetchMovies('trending/movie/week');
    nowPlayingMovies = fetchMovies('movie/now_playing');
    popularMovies = fetchMovies('movie/popular');
    topRatedMovies = fetchMovies('movie/top_rated'); // Fetch Top Rated
    upcomingMovies = fetchMovies('movie/upcoming'); // Fetch Upcoming

    // Fetch genre-specific movies (using TMDB genre IDs)
    actionMovies = fetchMovies('discover/movie', extraParams: {'with_genres': '28', 'sort_by': 'popularity.desc'}); // Action Genre ID 28
    horrorMovies = fetchMovies('discover/movie', extraParams: {'with_genres': '27', 'sort_by': 'popularity.desc'}); // Horror Genre ID 27
    familyMovies = fetchMovies('discover/movie', extraParams: {'with_genres': '10751', 'sort_by': 'popularity.desc'}); // Family Genre ID 10751

    // Keep existing categories
    comedyMovies = fetchMovies('discover/movie', extraParams: {'with_genres': '35',  'sort_by': 'popularity.desc' }); // Comedy Genre ID 35
    spaceMovies = fetchSpaceMovies(pages: 3); // Keep Space movies
  }

  // Fetches movies from a given TMDB endpoint (reused for categories)
  // Make sure this function uses widget.apiKey internally!
  Future<List<Movie>> fetchMovies(
      String endpoint, {
        Map<String, String>? extraParams,
        int page = 1,
      }) async {
    final params = {
      'api_key': widget.apiKey, // Use widget.apiKey
      'language': 'en-US',
      'page': '$page',
      if (extraParams != null) ...extraParams,
    };

    final uri = Uri.https(
      'api.themoviedb.org',
      '/3/$endpoint',
      params,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        print('Failed to load $endpoint (status ${response.statusCode})');
        return [];
      }

      final data = json.decode(response.body);
      return (data['results'] as List)
          .take(30) // Limit the number of movies per section
          .map((json) => Movie.fromJson(json))
          .where((movie) => movie.posterPath.isNotEmpty) // Filter out movies without posters
          .toList();
    } catch (e) {
      print('Error fetching $endpoint: $e');
      return [];
    }
  }

  // Helper to find the keyword ID for "space" (reused)
  // Make sure this function uses widget.apiKey internally!
  Future<int?> fetchSpaceKeyword() async {
    final uri = Uri.https(
      'api.themoviedb.org',
      '/3/search/keyword',
      {'api_key': widget.apiKey, 'query': 'space'}, // Use widget.apiKey
    );
    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final List results = json.decode(resp.body)['results'];
      return results.isNotEmpty ? results.first['id'] as int : null;
    } catch (e) {
      print('Error fetching space keyword: $e');
      return null;
    }
  }

  // Fetches Space/Sci-Fi movies using genre and keyword (reused)
  // Make sure this function uses widget.apiKey internally!
  Future<List<Movie>> fetchSpaceMovies({int pages = 3}) async {
    final keywordId = await fetchSpaceKeyword();
    if (keywordId == null) return [];

    List<Movie> all = [];
    // Using genre 878 (Science Fiction) and the 'space' keyword
    final params = {
      'api_key': widget.apiKey, // Use widget.apiKey
      'with_genres': '878',
      'with_keywords': '$keywordId',
      'sort_by': 'popularity.desc',
      'language': 'en-US',
    };

    for (var page = 1; page <= pages; page++) {
      final uri = Uri.https(
        'api.themoviedb.org',
        '/3/discover/movie',
        {...params, 'page': '$page'},
      );
      try {
        final resp = await http.get(uri);
        if (resp.statusCode != 200) break;
        final List results = json.decode(resp.body)['results'];
        all.addAll(results
            .map((j) => Movie.fromJson(j))
            .where((movie) => movie.posterPath.isNotEmpty));
      } catch (e) {
        print('Error fetching space movies page $page: $e');
        break;
      }
    }
    return all.take(50).toList(); // Limit total space movies if many pages
  }


  // Widget to build a beautiful horizontal section of movies
// In HomeScreen.dart (within the _HomeScreenState class)

// Ensure you have this import at the top of your HomeScreen.dart file:
// import 'movie_detail_screen.dart'; // Assuming your detail screen file is named movie_detail_screen.dart


  Widget _buildSection(String title, Future<List<Movie>>? movies) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12), // Reduced vertical padding slightly
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added vertical padding around title
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20, // Slightly reduced title font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ensure title color is white
              ),
            ),
          ),
          FutureBuilder<List<Movie>>(
            future: movies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 220, // Match the horizontal list height
                  child: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)), // Use theme color
                );
              }

              final categoryMovies = snapshot.data ?? [];
              if (snapshot.hasError || categoryMovies.isEmpty) {
                // Check for empty data as well
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                  child: Text(
                    'Could not load $title.',
                    style: TextStyle(color: Colors.grey), // Style error message
                  ),
                );
              }

              // Ensure movies with no poster are filtered out before building the list
              final moviesWithPosters = categoryMovies.where((m) => m.posterPath.isNotEmpty).toList();

              if (moviesWithPosters.isEmpty) {
                // This should ideally not happen if the fetch filters correctly,
                // but provides a fallback message.
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'No movies with posters available in $title.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return SizedBox(
                height: 220, // Adjusted height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moviesWithPosters.length,
                  itemBuilder: (context, index) {
                    final movie = moviesWithPosters[index]; // <-- Correctly get the movie object

                    return GestureDetector(
                      onTap: () {
                        // --- Changed: Navigate to MovieDetailScreen ---
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(
                              movie: movie,       // Pass the Movie object
                              apiKey: widget.apiKey, // Pass the API key
                            ),
                          ),
                        );
                        // --- End Changed ---
                      },
                      child: MovieCard(movie: movie), // Use MovieCard widget
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Hide back button in bottom nav screens
        backgroundColor: Color(0xFF0D1117),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arrange sections in a logical order
            _buildSection('Trending Movies', trendingMovies),
            _buildSection('Now in Theaters', nowPlayingMovies),
            _buildSection('Popular Movies', popularMovies),
            _buildSection('Top Rated', topRatedMovies), // Added Top Rated
            _buildSection('Upcoming', upcomingMovies), // Added Upcoming
            _buildSection('Action', actionMovies),     // Added Action
            _buildSection('Comedy', comedyMovies),     // Kept Comedy
            _buildSection('Horror', horrorMovies),     // Added Horror
            _buildSection('Family', familyMovies),     // Added Family
            _buildSection('Science Fiction', spaceMovies), // Kept Sci-Fi

            SizedBox(height: 20), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}


// --- MovieCard Widget (Adjusted Size) ---
// Ensure this widget is present and updated as below.
class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    // Check if posterPath is available before building the card
    if (movie.posterPath.isEmpty) {
      return SizedBox.shrink(); // Don't build the card if no poster
    }

    return Container(
      width: 130, // Decreased width
      margin: EdgeInsets.symmetric(horizontal: 6), // Adjusted horizontal margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( // Use Expanded to fill available vertical space
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w342${movie.posterPath}', // Use w342 or w500
                fit: BoxFit.cover,
                width: double.infinity, // Make image take full width of container
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40), // Nicer error icon
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Slightly smaller title font
            ),
          ),
          SizedBox(height: 2), // Small space
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 15), // Slightly smaller star icon
              SizedBox(width: 4),
              Text('${movie.rating.toStringAsFixed(1)}/10', style: TextStyle(fontSize: 12)), // Slightly smaller rating font
            ],
          ),
          SizedBox(height: 2), // Small space
          Text(
            // Safely get the year
            movie.releaseDate.isNotEmpty && movie.releaseDate != 'Unknown Date'
                ? movie.releaseDate.split('-').first
                : 'Year N/A',
            style: TextStyle(fontSize: 11, color: Colors.grey), // Slightly smaller year font
          ),
        ],
      ),
    );
  }
}

// --- Ensure the Movie class and other shared widgets/functions are present ---
// Movie, SearchMovieItem, RecommendedMovieItem, _RecommendedMovieDisplayItem,
// kApiKey, fetchTrailer, playTrailer