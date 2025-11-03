import 'package:cached_network_image/cached_network_image.dart';
import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:findmyshow/presentation/details_screen.dart';
import 'package:findmyshow/presentation/movie_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedMoviesPage extends StatefulWidget {
  const SavedMoviesPage({super.key});

  @override
  State<SavedMoviesPage> createState() => _SavedMoviesPageState();
}

class _SavedMoviesPageState extends State<SavedMoviesPage> {
  MovieCubit? movieCubit;
  List<MovieEntity> savedMovies = [];

  @override
  void initState() {
    super.initState();
    movieCubit = context.read<MovieCubit>();
    savedMovies = movieCubit?.savedMovies ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Movies'),
      ),
      body: SafeArea(
        child: BlocBuilder(
            bloc: movieCubit,
            buildWhen: (previous, current) {
              return current is MovieListUpdatedState;
            },
            builder: (context, state) {
              if (state is MovieListUpdatedState) {
                savedMovies = state.savedMovies;
              }
              return savedMovies.isEmpty
                  ? const Center(
                      child: Text(
                        'No saved movies yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: savedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = savedMovies[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailScreen(movie: movie),
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
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.broken_image,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title ?? "",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Year: ${movie.releaseDate ?? ""}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber, size: 18),
                                            SizedBox(width: 4),
                                            Text(
                                              movie.voteAverage.toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: IconButton(
                                    onPressed: () {
                                      movieCubit?.deleteSavedMovie(movie.id);
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            }),
      ),
    );
  }
}
