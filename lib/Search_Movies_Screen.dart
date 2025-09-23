import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'; // Assuming this is used by playTrailer
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart'; // Assuming this is used by playTrailer

// Import your other screens and shared components
import 'Movie_Detial_And_Play_Screen.dart';
import 'Recommendation_Movies_Screen.dart'; // Assuming this import is needed
import 'main.dart'; // Ensure Movie, fetchTrailer, and playTrailer are defined here or accessible



class SearchScreen extends StatefulWidget {
  final String apiKey;
  const SearchScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Movie>>? _searchResultsFuture; // Holds the future for either Top Rated or Search Results
  String _currentSearchQuery = ''; // Tracks the current search query (empty string for Top Rated)
  late Future<List<Movie>> _topRatedFuture; // Holds the future for the initial Top Rated fetch

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    // Fetch top-rated movies initially
    _topRatedFuture = _fetchTopRatedMovies();
    // Set the initial future to the top-rated future
    _searchResultsFuture = _topRatedFuture;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Listener for text changes to reset to top rated if the search bar is cleared
  void _onSearchTextChanged() {
    // If text becomes empty AND we were previously searching (query was not empty)
    if (_searchController.text.isEmpty && _currentSearchQuery.isNotEmpty) {
      // Perform a search with an empty query, which _performSearch handles by resetting
      _performSearch('');
    }
    // If text is not empty, no need to do anything here, onSubmitted handles triggering search
  }

  // Fetches top-rated movies from TMDB
  Future<List<Movie>> _fetchTopRatedMovies() async {
    final uri = Uri.https(
      'api.themoviedb.org',
      '/3/movie/top_rated',
      {
        'api_key': widget.apiKey,
        'language': 'en-US',
        'page': '1',
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results
            .map((json) => Movie.fromJson(json))
            .where((movie) => movie.posterPath.isNotEmpty)
            .take(10) // Take only the top 10 for the initial view
            .toList();
      } else {
        print('Failed to fetch top-rated movies (status ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching top-rated: $e');
    }
    return []; // Return empty list on error
  }

  // Searches movies by query on TMDB
  Future<List<Movie>> _searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.https(
      'api.themoviedb.org',
      '/3/search/movie',
      {
        'api_key': widget.apiKey,
        'query': query,
        'language': 'en-US',
        'page': '1', // Usually only need the first page for search results
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results
            .map((json) => Movie.fromJson(json))
            .where((movie) => movie.posterPath.isNotEmpty) // Filter out movies without posters
            .toList();
      } else {
        print('Search API failed (status ${response.statusCode})');
      }
    } catch (e) {
      print('Error during search: $e');
    }
    return []; // Return empty list on error
  }

  // Performs the search or resets to top rated
  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    // Only trigger a state update if the query or the future is changing
    if (trimmed == _currentSearchQuery && (_searchResultsFuture != null || trimmed.isEmpty)) {
      return; // Avoid unnecessary setState calls if state is the same
    }


    if (trimmed.isEmpty) {
      // If query is empty, show top-rated movies
      setState(() {
        _searchResultsFuture = _topRatedFuture; // Reset to the pre-fetched top-rated
        _currentSearchQuery = ''; // Clear the current query state
      });
    } else {
      // If query is not empty, perform a new search
      setState(() {
        _currentSearchQuery = trimmed; // Set the current query state
        _searchResultsFuture = _searchMovies(trimmed); // Set the new search future
      });
    }
    // No need to await the future here, FutureBuilder handles it.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70, // Increased height
        title: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white24, // Subtle background for dark theme search bar
            borderRadius: BorderRadius.circular(10),
            boxShadow: [ // Subtle shadow
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              autofocus: true, // Auto-focus when screen opens
              cursorColor: Colors.white, // White cursor on dark background
              decoration: InputDecoration(
                hintText: 'Search movies...',
                hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                border: InputBorder.none, // No visible border line
                prefixIcon: Icon(Icons.search, color: Colors.white70, size: 24), // White/grey icon
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white70), // White/grey icon
                  onPressed: () => _searchController.clear(), // Clearing text field triggers listener
                )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Adjusted padding
              ),
              style: TextStyle(color: Colors.white, fontSize: 18), // White text input
              onSubmitted: (q) => _performSearch(q.trim()), // Trigger search on submit
              textInputAction: TextInputAction.search, // Show search icon on keyboard
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Hide back button in bottom nav screens
        centerTitle: true,
      ),
      body: _buildSearchResults(), // Call the builder method for results content
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _currentSearchQuery.isEmpty
                ? 'Top Rated Movies' // Title when search bar is empty (showing top rated)
                : 'Search Results for "$_currentSearchQuery"', // Title when searching
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // White title color
          ),
        ),
        Expanded( // Use Expanded to make the list/grid take the remaining space
          child: FutureBuilder<List<Movie>>(
            future: _searchResultsFuture, // This future holds either Top Rated or Search Results
            builder: (context, snapshot) { // Use snapshot for clarity
              // Show loading spinner while the future is waiting
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)); // Use theme color
              }

              // Get the list of movies from the snapshot data
              final movies = snapshot.data ?? []; // Correctly access data from snapshot

              // Handle empty state *after* future has completed
              if (movies.isEmpty) {
                return Center(
                  child: Text(
                    _currentSearchQuery.isEmpty
                        ? 'No top-rated movies found' // Message if top-rated fetch was empty
                        : 'No movies found for "$_currentSearchQuery"', // Message if search yielded no results
                    style: TextStyle(color: Colors.white70, fontSize: 16), // White/grey message color
                  ),
                );
              }

              // If search query is empty, display Top Rated in a GridView
              if (_currentSearchQuery.isEmpty) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    childAspectRatio: 0.65, // Aspect ratio of each grid item
                    crossAxisSpacing: 16, // Horizontal space
                    mainAxisSpacing: 16, // Vertical space
                  ),
                  itemCount: movies.length, // Use the movies list
                  itemBuilder: (context, index) { // Use context, index
                    final movie = movies[index]; // Get the movie object

                    // Ensure movie has a poster before trying to build the card
                    if (movie.posterPath.isEmpty) {
                      return SizedBox.shrink(); // Don't build the card if no poster
                    }

                    // Stagger effect (optional, keep if desired)
                    return Container(
                      margin: EdgeInsets.only(top: index % 2 == 0 ? 20 : 0), // left column down
                      child: GestureDetector(
                        onTap: () {
                          // --- Keep Original Behavior for Top Rated Grid Items ---
                          // Fill search bar with the movie title and perform a search for it
                          _searchController.text = movie.title;
                          _performSearch(movie.title);
                          // --- End Original Behavior ---
                        },
                        // Use a standard Card structure for Top Rated items
                        child: Card(
                          elevation: 6, // Add elevation
                          color: Theme.of(context).cardColor, // Use theme card color (dark grey)
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)), // Rounded corners
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded( // Image takes remaining vertical space
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(12)),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}', // Use movie.posterPath
                                    fit: BoxFit.cover,
                                    placeholder: (ctx, url) => Container( // Placeholder with theme colors
                                      color: Theme.of(context).cardColor,
                                      child: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2)),
                                    ),
                                    errorWidget: (ctx, url, err) => Container( // Error widget with theme colors
                                      color: Theme.of(context).cardColor,
                                      child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.error, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  movie.title, // Use movie.title
                                  // Use theme text style for consistency on dark background
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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

              // If search query is NOT empty, display Search Results in a ListView
              // This uses your existing SearchMovieItem widget structure
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                itemCount: movies.length, // Use the movies list (search results)
                separatorBuilder: (context, index) => Padding( // Use context, index
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1, color: Colors.grey[800]), // Use a dark grey divider
                ),
                itemBuilder: (context, index) { // Use context, index
                  final movie = movies[index]; // <-- Correctly get the movie object for the list item

                  // Ensure movie has a poster before trying to build the item
                  if (movie.posterPath.isEmpty) {
                    return SizedBox.shrink(); // Don't build item if no poster
                  }

                  // Wrap the SearchMovieItem in a GestureDetector (or InkWell) to make it tappable
                  return GestureDetector( // Or InkWell if you prefer ink splash effect
                    onTap: () {
                      // --- Updated: Navigate to MovieDetailScreen for Search Results ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            movie: movie,       // Pass the Movie object 'movie'
                            apiKey: widget.apiKey, // Pass the API key
                            // Do NOT pass similarityScore, as requested
                          ),
                        ),
                      );
                      // --- End Updated ---
                    },
                    child: SearchMovieItem(movie: movie), // Use the SearchMovieItem widget for appearance
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Ensure Movie and SearchMovieItem classes are defined and accessible ---
// (e.g., in main.dart or separate files like models/movie.dart, widgets/search_movie_item.dart)
// --- Ensure fetchTrailer and playTrailer functions are defined and accessible ---
// (e.g., in main.dart or a separate api_service.dart file)
// --- Ensure MovieDetailScreen class is defined and imported ---
// (in movie_detail_screen.dart, accepting Movie and apiKey)