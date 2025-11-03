import 'package:dio/dio.dart';
import 'package:findmyshow/data/api_client.dart';
import 'package:findmyshow/data/endpoint/movieEndpoint.dart';
import 'package:findmyshow/data/local_data_store/hive_wrapper.dart';
import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:findmyshow/data/models/movie.dart';

/// Repository contract to fetch movies mapped into domain entities.
abstract class MovieRepository {
  Future<List<MovieEntity>> getTrendingMovies({bool forceRefresh = false});
  Future<List<MovieEntity>> getNowPlayingMovies({bool forceRefresh = false});
}

class MovieRepositoryImpl implements MovieRepository {
  final MovieEndpoint movieEndpoint;
  final String _apiKey;
  final LocalDataStore _localDataStore;

  MovieRepositoryImpl(
      {MovieEndpoint? api, String? apiKey, LocalDataStore? localDataStore})
      : movieEndpoint = api ?? ApiClient.createMovieEndpoint(),
        _apiKey = apiKey ?? ApiClient.apiKey,
        _localDataStore = localDataStore ?? LocalDataStore();

  @override
  Future<List<MovieEntity>> getTrendingMovies(
      {bool forceRefresh = false}) async {
    final cached = await _localDataStore.fetchBaseTrendingMovies();
    if (!forceRefresh && cached.isNotEmpty) {
      return cached.map(_mapToEntity).toList();
    }
    final response =
        await _safeCall(() => movieEndpoint.getTrendingMovies(_apiKey));
    await _localDataStore.saveBaseTrendingMovie(response.results);
    return response.results.map(_mapToEntity).toList();
  }

  @override
  Future<List<MovieEntity>> getNowPlayingMovies(
      {bool forceRefresh = false}) async {
    final cached = await _localDataStore.fetchBaseNowPlayingMovies();
    if (!forceRefresh && cached.isNotEmpty) {
      return cached.map(_mapToEntity).toList();
    }
    final response =
        await _safeCall(() => movieEndpoint.getNowPlayingMovies(_apiKey));
    await _localDataStore.saveBaseNowPlayingMovie(response.results);
    return response.results.map(_mapToEntity).toList();
  }

  MovieEntity _mapToEntity(Movie m) => MovieEntity(
        id: m.id,
        title: m.title,
        posterPath: m.poster_path,
        overview: m.overview,
        releaseDate: m.release_date,
        voteAverage: m.vote_average,
      );

  Future<MovieResponse> _safeCall(
      Future<MovieResponse> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
