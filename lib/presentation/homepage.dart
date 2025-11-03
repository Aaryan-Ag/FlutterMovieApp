import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:findmyshow/presentation/movie_cubit.dart';
import 'package:findmyshow/presentation/saved_movies.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'details_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.movieId});
  final String? movieId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  MovieCubit movieCubit = MovieCubit();
  List<MovieEntity> allMovies = [];
  String searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode(canRequestFocus: true);
  late TabController _tabController;
  bool _deepLinkHandled = false;

  String _buildShareText(MovieEntity movie) {
    final title = movie.title ?? 'Untitled';
    final year = (movie.releaseDate ?? '').isNotEmpty
        ? movie.releaseDate
        : 'Unknown Year';
    final rating = (movie.voteAverage ?? 0).toString();
    final overview = (movie.overview ?? '').trim();
    final overviewSnippet = overview.isEmpty
        ? ''
        : (overview.length > 140 ? '${overview.substring(0, 140)}…' : overview);
    final link = 'https://findmyshow.com/movie/${movie.id}';
    return [
      '🎬 $title',
      if (year != null) 'Year: $year',
      'Rating: $rating/10',
      if (overviewSnippet.isNotEmpty) overviewSnippet,
      'More details: $link'
    ].join('\n');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await movieCubit.fetchSavedMovies();
      await movieCubit.fetchMovies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    movieCubit.close();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void handleSearch(String query) {
    searchQuery = query;
    movieCubit.searchMovies(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => movieCubit,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _searchFocusNode.canRequestFocus = false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Browse Movies'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: movieCubit,
                    child: SavedMoviesPage(),
                  ),
                ),
              );
            },
            backgroundColor: Colors.grey[300],
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark,
                  color: Colors.blue,
                ),
                Text(
                  "Saved Movies",
                  style: TextStyle(fontSize: 14), // small text
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.blue,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Now playing movies'),
                    Tab(text: 'Trending movies'),
                  ],
                  onTap: (_) {
                    movieCubit.tabBarSwitched();
                    FocusScope.of(context).unfocus();
                  },
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Listener(
                    onPointerDown: (_) {
                      _searchFocusNode.canRequestFocus = true;
                    },
                    child: TextField(
                      focusNode: _searchFocusNode,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search movies...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        handleSearch(value);
                      },
                    ),
                  ),
                ),
                // Swipeable views for tabs
                Expanded(
                  child: BlocListener<MovieCubit, MovieState>(
                    listenWhen: (prev, curr) => curr is MovieListUpdatedState,
                    listener: (context, state) {
                      if (widget.movieId != null &&
                          !_deepLinkHandled &&
                          state is MovieListUpdatedState) {
                        final allMovies = [
                          ...state.nowPlayingMovies,
                          ...state.trendingMovies,
                        ];
                        try {
                          final movie = allMovies.firstWhere(
                            (m) => m.id.toString() == widget.movieId,
                          );
                          _deepLinkHandled =
                              true; // prevent multiple navigations
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailScreen(movie: movie),
                                ),
                              );
                            }
                          });
                        } catch (_) {
                          // Movie not found; optionally show a message
                          _deepLinkHandled = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Movie not found for deep link')),
                          );
                        }
                      }
                    },
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        BlocBuilder<MovieCubit, MovieState>(
                          buildWhen: (previous, current) {
                            return current is MovieLoading ||
                                current is MovieError ||
                                current is MovieListUpdatedState;
                          },
                          builder: (context, state) {
                            // if (widget.movieId != null &&
                            //     movieCubit.state is MovieListUpdatedState) {
                            //   final state =
                            //       movieCubit.state as MovieListUpdatedState;
                            //   final allMovies = [
                            //     ...state.nowPlayingMovies,
                            //     ...state.trendingMovies
                            //   ];
                            //   try {
                            //     final movie = allMovies.firstWhere(
                            //         (m) => m.id.toString() == widget.movieId,
                            //         orElse: () =>
                            //             throw Exception('Movie not found'));
                            //     if (mounted) {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (_) => MovieDetailScreen(
                            //             movie: movie,
                            //           ),
                            //         ),
                            //       );
                            //     }
                            //   } catch (e) {
                            //     // Optionally handle the case where the movie is not found
                            //   }
                            // }
                            if (state is MovieLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is MovieError) {
                              return RefreshIndicator(
                                onRefresh: () =>
                                    movieCubit.refreshNowPlayingMovies(),
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: Text(
                                              'Error loading movies please pull down to refresh')),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is MovieListUpdatedState) {
                              final movies = state.nowPlayingMovies;
                              if (movies.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () =>
                                      movieCubit.refreshNowPlayingMovies(),
                                  child: ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(
                                        height: 200,
                                        child: Center(
                                            child: Text('No movies available')),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return RefreshIndicator(
                                onRefresh: () =>
                                    movieCubit.refreshNowPlayingMovies(),
                                child: _movieEntityList(movies),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        BlocBuilder<MovieCubit, MovieState>(
                          buildWhen: (previous, current) {
                            return current is MovieLoading ||
                                current is MovieError ||
                                current is MovieListUpdatedState;
                          },
                          builder: (context, state) {
                            if (state is MovieLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is MovieError) {
                              return RefreshIndicator(
                                onRefresh: () =>
                                    movieCubit.refreshNowPlayingMovies(),
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: Text(
                                              'Error loading movies please pull down to refresh')),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is MovieListUpdatedState) {
                              final movies = state.trendingMovies;
                              if (movies.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () =>
                                      movieCubit.refreshTrendingMovies(),
                                  child: ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(
                                        height: 200,
                                        child: Center(
                                            child: Text('No movies available')),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return RefreshIndicator(
                                onRefresh: () =>
                                    movieCubit.refreshTrendingMovies(),
                                child: _movieEntityList(movies),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _movieEntityList(List<MovieEntity> movies) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(
                    movie:
                        movie, // MovieDetailScreen expects domain MovieEntity? adjust if needed
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: movie.title ?? "",
                  child: CachedNetworkImage(
                    imageUrl:
                        "https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}",
                    height: 150,
                    width: 100,
                    memCacheHeight: 150,
                    memCacheWidth: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Year: ${movie.releaseDate ?? ""}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              (movie.voteAverage ?? 0).toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        movieCubit.saveUnsaveSelectedMovie(movie);
                      },
                      icon: Icon(
                        movieCubit.isMovieSaved(movie.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final shareText = _buildShareText(movie);
                        Share.share(shareText);
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
