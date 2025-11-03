import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:findmyshow/domain/repository/movie_repository.dart';

/// Use case layer for movie-related operations.
/// Keeps UI/business logic decoupled from data/repository implementation details.
class MovieUseCase {
  final MovieRepository _repository;

  MovieUseCase(this._repository);

  /// Get trending movies mapped as domain entities.
  Future<List<MovieEntity>> getTrendingMovies({bool forceRefresh = false}) {
    return _repository.getTrendingMovies(forceRefresh: forceRefresh);
  }

  /// Get now playing movies mapped as domain entities.
  Future<List<MovieEntity>> getNowPlayingMovies({bool forceRefresh = false}) {
    return _repository.getNowPlayingMovies(forceRefresh: forceRefresh);
  }
}
