import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/movie.dart';

part 'movieEndpoint.g.dart';

@RestApi(baseUrl: "https://api.themoviedb.org/3")
abstract class MovieEndpoint {
  factory MovieEndpoint(Dio dio, {String baseUrl}) = _MovieEndpoint;

  @GET("/trending/movie/day")
  Future<MovieResponse> getTrendingMovies(@Query("api_key") String apiKey);

  @GET("/movie/now_playing")
  Future<MovieResponse> getNowPlayingMovies(@Query("api_key") String apiKey);
}

@JsonSerializable()
class MovieResponse {
  final int page;
  final List<Movie> results;

  MovieResponse({required this.page, required this.results});

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}
