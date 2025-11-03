import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  final int id;
  final String? title;
  final String? poster_path;
  final String? overview;
  final String? release_date;
  final double? vote_average;

  Movie({
    required this.id,
    this.title,
    this.poster_path,
    this.overview,
    this.release_date,
    this.vote_average,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
