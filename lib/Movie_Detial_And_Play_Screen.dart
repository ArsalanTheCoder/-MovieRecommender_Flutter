import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:youtube_player_iframe/youtube_player_iframe.dart'; // For playTrailer
import 'package:http/http.dart' as http; // For fetching movie details
import 'dart:convert';

import 'Recommendation_Movies_Screen.dart';
import 'main.dart'; // For JSON decoding

// Import necessary items from your main file or shared files
// Ensure Movie class is defined and accessible
// Ensure kApiKey, fetchTrailer, playTrailer functions are defined and accessible

// Example Imports (adjust based on your file structure)
// import 'main.dart'; // Assuming kApiKey, fetchTrailer, playTrailer are here
// import 'models/movie.dart'; // If Movie class is in a separate file


// Assuming Movie class is defined and accessible
/*
class Movie {
  final int id;
  final String title;
  final String posterPath; // Use this for the image
  final double rating;
  final String releaseDate;
  final String overview;
  // Add more fields if your initial Movie object has them, but we'll fetch more details here
  Movie({required this.id, required this.title, required this.posterPath, required this.rating, required this.releaseDate, required this.overview});

  factory Movie.fromJson(Map<String, dynamic> json) {
     return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'] ?? '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? 'Unknown Date',
      overview: json['overview'] ?? 'No overview available.',
    );
  }
}
*/


class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final String apiKey; // Need API key to fetch trailer and full details
  // Optional: Receive similarity score if coming from recommendations
  final double? similarityScore;

  const MovieDetailScreen({
    Key? key,
    required this.movie,
    required this.apiKey,
    this.similarityScore, // Accept optional similarity score
  }) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<String?>? _trailerIdFuture; // Future for trailer key
  Future<Map<String, dynamic>?>? _detailedMovieDataFuture; // Future for full movie details

  // --- Declare Color variables as late ---
  // They will be initialized in didChangeDependencies
  late Color _cardBgColor;
  late Color _textColor;
  late Color _secondaryTextColor;
  late Color _accentColor;
  late Color _errorColor;
  // --- End Declare Color variables ---


  @override
  void initState() {
    super.initState();
    // Fetch data that does NOT depend on the widget's context (like Theme or MediaQuery)
    _trailerIdFuture = fetchTrailer(widget.movie.id, widget.apiKey);
    _detailedMovieDataFuture = _fetchMovieDetails(widget.movie.id, widget.apiKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // --- Initialize Theme-Dependent Variables Here ---
    // This method is called after initState and when dependencies (like Theme) change.
    // Use this to get theme-dependent values.
    final theme = Theme.of(context);
    _cardBgColor = theme.cardColor;
    _textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;
    _secondaryTextColor = theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;
    _accentColor = theme.primaryColor;
    _errorColor = theme.colorScheme.error;
    // --- End Initialize Theme-Dependent Variables ---
  }


  // --- Method to Fetch Full Movie Details ---
  Future<Map<String, dynamic>?> _fetchMovieDetails(int movieId, String apiKey) async {
    final uri = Uri.https(
      'api.themoviedb.org',
      '/3/movie/$movieId', // Endpoint for specific movie details
      {
        'api_key': apiKey,
        'language': 'en-US',
        'append_to_response': 'credits' // Append credits to get crew (for director)
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json; // Return the raw JSON map
      } else {
        print('Failed to fetch movie $movieId details (status ${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('Error fetching movie $movieId details: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Calculate the height for the poster image
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageHeight = screenWidth * 0.6; // Adjust this multiplier (e.g., 0.5 to 0.7)

    return Scaffold(
      // Scaffold background is dark from the main theme
      extendBodyBehindAppBar: true, // Extend body content behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        // Using movie title here, it will be visible if there's a gradient over the poster
        title: Text(widget.movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)), // White title color
        centerTitle: true,
        // Back button is automatically provided by Navigator.push
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Movie Poster/Image Section ---
            Stack( // Use Stack to layer image and gradient/title
              children: [
                // Image (Poster)
                Container(
                  width: screenWidth,
                  height: imageHeight,
                  child: widget.movie.posterPath.isEmpty
                      ? Container( // Placeholder if no poster
                    color: _cardBgColor, // Use initialized color
                    child: Icon(Icons.movie_filter_outlined, size: 80, color: _secondaryTextColor.withOpacity(0.5)),
                  )
                      : CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}', // Use w500 for detail page
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: _cardBgColor, // Placeholder background
                      child: Center(child: CircularProgressIndicator(color: _accentColor, strokeWidth: 2)), // Loader color
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: _cardBgColor, // Error background
                      child: Icon(Icons.broken_image, size: 80, color: _errorColor), // Error icon color
                    ),
                  ),
                ),
                // Gradient overlay for better text visibility on image
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6), // Dark gradient at top
                        Colors.transparent,
                        // Use a color that matches your dark theme background here to fade nicely
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9), // Fade to dark background
                      ],
                      stops: [0.0, 0.5, 1.0], // Adjust gradient stops
                    ),
                  ),
                ),
              ],
            ),

            // --- Movie Details Section ---
            // --- FIX: Wrap the Container in Transform.translate and remove negative margin ---
            Transform.translate(
              offset: const Offset(0, -20), // Apply upward visual translation
              child: Container(
                width: screenWidth, // Take full width
                // REMOVED: margin: EdgeInsets.only(top: -20), // <-- REMOVED THIS LINE
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor, // Use the main dark background color
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)) // Rounded top corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Padding inside the container
                child: FutureBuilder<Map<String, dynamic>?>(
                    future: _detailedMovieDataFuture, // Listen to the future for detailed data
                    builder: (context, snapshot) {
                      // Show loader while fetching detailed data
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: _accentColor)); // Use initialized color
                      }

                      // Handle error or no data found for detailed fetch
                      if (snapshot.hasError || !snapshot.hasData) {
                        print("Detailed movie data fetch error: ${snapshot.error}");
                        // Build a section with just the basic info we already have if detailed fetch fails
                        return _buildBasicDetails(); // Call helper for basic details, now no context param needed
                      }

                      // --- Detailed Data is Available ---
                      final detailedData = snapshot.data!;
                      // Extract data safely, providing defaults if null
                      final genres = (detailedData['genres'] as List?)?.map((g) => g['name'] as String).where((name) => name.isNotEmpty).toList() ?? [];
                      final crew = detailedData['credits']?['crew'] as List?; // Access 'credits' then 'crew'
                      final director = crew?.firstWhere((c) => c['job'] == 'Director', orElse: () => null)?['name'] as String?;
                      final runtime = detailedData['runtime'] as int?; // Runtime in minutes

                      // Build the full details section
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Movie Title (Prominently Displayed Below Poster) ---
                          Text(
                            widget.movie.title,
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _textColor, // Use initialized color
                                fontSize: 24 // Make title larger
                            ),
                          ),
                          SizedBox(height: 16), // Space after title

                          // --- Rating / Release Date / Runtime / Similarity ---
                          _buildRatingDateRuntimeSimilarityRow(runtime), // Pass runtime

                          SizedBox(height: 16), // Space after this row

                          // --- Genres ---
                          if (genres.isNotEmpty)
                            _buildGenresSection(genres), // Pass genres

                          if (genres.isNotEmpty) SizedBox(height: 16), // Add spacing only if genres were shown


                          // --- Director ---
                          if (director != null && director.isNotEmpty)
                            _buildDirectorSection(director), // Pass director

                          if (director != null && director.isNotEmpty) SizedBox(height: 16), // Add spacing only if director was shown


                          // --- Watch Trailer Button ---
                          // This FutureBuilder is independent as it uses _trailerIdFuture
                          _buildTrailerButtonSection(), // Call helper

                          SizedBox(height: 24), // Space after trailer button

                          // --- Overview ---
                          Text('Overview', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: _textColor)), // Styled title
                          SizedBox(height: 8),
                          Text(
                            widget.movie.overview.isNotEmpty && widget.movie.overview != 'No overview available.'
                                ? widget.movie.overview
                                : 'No overview available for this movie.',
                            style: Theme.of(context).textTheme.bodyMedium, // Inherits theme style
                          ),

                          SizedBox(height: 24), // Space at the bottom
                        ],
                      );
                    }
                ),
              ),
            ),
            const SizedBox(height: 20), // Add some space below the details container
          ],
        ),
      ),
    );
  }

  // --- Helper Methods for Building UI Sections ---

  // Builds the basic details section if detailed fetch fails
  // Renamed to avoid collision if context was passed, now uses state vars and widget.movie
  Widget _buildBasicDetails() {
    // Replicates parts of the layout using only data from the initial Movie object
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (Prominently Displayed Below Poster)
        Text(
          widget.movie.title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: _textColor,
              fontSize: 24
          ),
        ),
        SizedBox(height: 16),

        _buildRatingDateRuntimeSimilarityRow(null), // Show rating/date, null for runtime
        SizedBox(height: 16),

        _buildTrailerButtonSection(), // Watch Trailer Button (uses _trailerIdFuture)
        SizedBox(height: 24),

        // Overview
        Text('Overview', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: _textColor)),
        SizedBox(height: 8),
        Text(
          widget.movie.overview.isNotEmpty && widget.movie.overview != 'No overview available.'
              ? widget.movie.overview
              : 'No overview available for this movie.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 24),
      ],
    );
  }


  // Builds the row with Rating, Release Date, Runtime, and Similarity
  Widget _buildRatingDateRuntimeSimilarityRow(int? runtime) {
    String year = widget.movie.releaseDate.isNotEmpty && widget.movie.releaseDate != 'Unknown Date'
        ? widget.movie.releaseDate.split('-').first
        : 'N/A';

    String runtimeText = runtime != null ? '$runtime min' : 'N/A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
      children: [
        // Rating
        Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 20),
        SizedBox(width: 4),
        Text(
          '${widget.movie.rating.toStringAsFixed(1)}/10',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: _textColor), // Use initialized color
        ),
        SizedBox(width: 16),

        // Release Year
        Icon(Icons.calendar_today_rounded, color: _secondaryTextColor.withOpacity(0.8), size: 18), // Use initialized color
        SizedBox(width: 4),
        Text(
          year,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: _secondaryTextColor), // Use initialized color
        ),
        SizedBox(width: 16),

        // Runtime (only if available)
        if (runtime != null) ...[
          Icon(Icons.timer_rounded, color: _secondaryTextColor.withOpacity(0.8), size: 18), // Use initialized color
          SizedBox(width: 4),
          Text(
            runtimeText,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: _secondaryTextColor), // Use initialized color
          ),
          SizedBox(width: 16), // Add spacing after runtime if similarity score follows
        ],

        // Display Similarity Score here if passed
        if (widget.similarityScore != null) ...[
          Icon(Icons.compare_arrows_rounded, color: _accentColor.withOpacity(0.8), size: 18), // Use initialized color
          SizedBox(width: 4),
          Text(
            'Match: ${(widget.similarityScore! * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: _accentColor, fontWeight: FontWeight.bold), // Use initialized color
          ),
        ],
      ],
    );
  }

  // Builds the Genres section
  Widget _buildGenresSection(List<String> genres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genres', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: _textColor)), // Use initialized color
        SizedBox(height: 8),
        // Use Wrap for genres to flow to the next line if needed
        Wrap(
          spacing: 8.0, // Horizontal space between chips
          runSpacing: 4.0, // Vertical space between lines of chips
          children: genres.map((genre) => Chip(
            label: Text(genre, style: TextStyle(fontSize: 12, color: _textColor)), // Use initialized color
            backgroundColor: _cardBgColor, // Use initialized color
            shape: RoundedRectangleBorder( // Rounded corners
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _secondaryTextColor.withOpacity(0.3)), // Use initialized color
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          )).toList(),
        ),
      ],
    );
  }

  // Builds the Director section
  Widget _buildDirectorSection(String directorName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Director', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: _textColor)), // Use initialized color
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: _secondaryTextColor.withOpacity(0.8), size: 18), // Use initialized color
            SizedBox(width: 4),
            Text(directorName, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: _secondaryTextColor)), // Use initialized color
          ],
        ),
      ],
    );
  }


  // Builds the Watch Trailer Button section
  Widget _buildTrailerButtonSection() {
    return FutureBuilder<String?>(
      future: _trailerIdFuture, // Listen to the trailer fetch future
      builder: (context, snapshot) {
        // Show loader while fetching trailer ID
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _accentColor)); // Use initialized color
        }

        // If trailer ID is available
        if (snapshot.hasData && snapshot.data != null) {
          final trailerId = snapshot.data!;
          return Center( // Center the button
            child: ElevatedButton.icon(
              onPressed: () {
                // Use the shared playTrailer function (defined elsewhere, e.g., main.dart)
                playTrailer(context, trailerId);
              },
              icon: Icon(Icons.play_circle_fill_rounded, size: 24), // Styled icon
              label: Text('Watch Trailer'),
              style: ElevatedButton.styleFrom(
                // Colors are inherited from the theme's ElevatedButtonThemeData
                // primaryColor=Theme.of(context).primaryColor (BlueAccent)
                // onPrimary=Theme.of(context).colorScheme.onPrimary (White)
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14), // Larger padding
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Larger, bolder text
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded shape
              ),
            ),
          );
        }

        // If no trailer is available or error occurred
        return Center( // Center the button/message
          child: Text(
            'Trailer not available',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic, color: _secondaryTextColor.withOpacity(0.7)), // Use initialized color
          ),
        );
      },
    );
  }

}

// --- Ensure Movie class is defined or imported ---
// --- Ensure fetchTrailer and playTrailer functions are defined and accessible ---
// --- Ensure kApiKey is defined and accessible ---