import 'package:cached_network_image/cached_network_image.dart';
import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  final MovieEntity movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title ?? ""),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: movie.title ?? "",
              child: CachedNetworkImage(
                imageUrl:
                    "https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}",
                height: 400,
                memCacheHeight: 400,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Released: ${movie.releaseDate ?? ""}',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 22),
                      SizedBox(width: 6),
                      Text(
                        movie.voteAverage.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    movie.overview ?? "",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
