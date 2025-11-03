class MovieEntity {
  final int id;
  final String? title;
  final String? posterPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;

  MovieEntity({
    required this.id,
    this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
  });
}
