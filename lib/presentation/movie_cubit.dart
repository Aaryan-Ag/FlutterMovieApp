import 'package:findmyshow/data/local_data_store/hive_wrapper.dart';
import 'package:findmyshow/data/models/movie.dart';
import 'package:findmyshow/domain/entity/movie_entity.dart';
import 'package:findmyshow/domain/repository/movie_repository.dart';
import 'package:findmyshow/domain/usecase/movie_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieCubit extends Cubit<MovieState> {
  MovieCubit() : super(MovieInitial());

  int selectedIndex = 0;
  List<MovieEntity> savedMovies = [];
  List<MovieEntity> trendingMovies = [];
  List<MovieEntity> nowPlayingMovies = [];
  List<MovieEntity> baseTrendingMovies = [];
  List<MovieEntity> baseNowPlayingMovies = [];
  MovieUseCase movieUseCase = MovieUseCase(MovieRepositoryImpl());
  final localDataStore = LocalDataStore();
  String searchQuery = '';

  Future<void> fetchMovies({bool forceRefresh = false}) async {
    //implement force refresh logic
    try {
      emit(MovieLoading());

      final results = await Future.wait([
        movieUseCase.getTrendingMovies(forceRefresh: forceRefresh),
        movieUseCase.getNowPlayingMovies(forceRefresh: forceRefresh),
      ]);

      final trendingResponse = results[0];
      final nowPlayingResponse = results[1];

      baseTrendingMovies = List.from(trendingResponse);
      baseNowPlayingMovies = List.from(nowPlayingResponse);
      _applySearchAndUpdateLists();

      emit(
          MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
    } catch (e) {
      emit(MovieError('Error fetching movies: $e'));
    }
  }

  void searchMovies(String query) {
    searchQuery = query;
    _applySearchAndUpdateLists();
    emit(MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
  }

  void tabBarSwitched() {
    emit(MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
  }

  Future<void> saveUnsaveSelectedMovie(MovieEntity movie) async {
    final exists = savedMovies.any((m) => m.id == movie.id);
    if (exists) {
      await localDataStore.deleteSavedMovie(movie.id);
    } else {
      await localDataStore.saveMovie(Movie(
        id: movie.id,
        title: movie.title,
        poster_path: movie.posterPath,
        overview: movie.overview,
        release_date: movie.releaseDate,
        vote_average: movie.voteAverage,
      ));
    }
    savedMovies =
        (await localDataStore.fetchAllSavedMovies()).map(_mapToEntity).toList();
    _applySearchAndUpdateLists();
    emit(MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
  }

  Future<void> fetchSavedMovies() async {
    savedMovies =
        (await localDataStore.fetchAllSavedMovies()).map(_mapToEntity).toList();
  }

  bool isMovieSaved(int id) {
    return savedMovies.any((m) => m.id == id);
  }

  Future<void> deleteSavedMovie(int id) async {
    await localDataStore.deleteSavedMovie(id);
    savedMovies =
        (await localDataStore.fetchAllSavedMovies()).map(_mapToEntity).toList();
    emit(MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
  }

  Future<void> refreshNowPlayingMovies() async {
    try {
      final nowPlayingResponse =
          await movieUseCase.getNowPlayingMovies(forceRefresh: true);
      baseNowPlayingMovies = List.from(nowPlayingResponse);
      _applySearchAndUpdateLists();
      emit(
          MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
    } catch (e) {
      if (baseNowPlayingMovies.isNotEmpty) {
      } else {
        emit(MovieError('Error refreshing now playing movies: $e'));
      }
    }
  }

  Future<void> refreshTrendingMovies() async {
    try {
      final trendingResponse =
          await movieUseCase.getTrendingMovies(forceRefresh: true);
      baseTrendingMovies = List.from(trendingResponse);
      _applySearchAndUpdateLists();
      emit(
          MovieListUpdatedState(trendingMovies, nowPlayingMovies, savedMovies));
    } catch (e) {
      if (baseTrendingMovies.isNotEmpty) {
      } else {
        emit(MovieError('Error refreshing trending movies: $e'));
      }
    }
  }

  // Movie _mapToEntity(MovieEntity m) => Movie(
  //       id: m.id,
  //       title: m.title,
  //       poster_path: m.posterPath,
  //       overview: m.overview,
  //       release_date: m.releaseDate,
  //       vote_average: m.voteAverage,
  //     );

  MovieEntity _mapToEntity(Movie m) => MovieEntity(
        id: m.id,
        title: m.title,
        posterPath: m.poster_path,
        overview: m.overview,
        releaseDate: m.release_date,
        voteAverage: m.vote_average,
      );

  void _applySearchAndUpdateLists() {
    if (searchQuery.isEmpty) {
      trendingMovies = List.from(baseTrendingMovies);
      nowPlayingMovies = List.from(baseNowPlayingMovies);
    } else {
      trendingMovies = baseTrendingMovies
          .where((movie) => (movie.title ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
      nowPlayingMovies = baseNowPlayingMovies
          .where((movie) => (movie.title ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
  }
}

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieError extends MovieState {
  final String message;

  MovieError(this.message);
}

class MovieListUpdatedState extends MovieState {
  final List<MovieEntity> trendingMovies;
  final List<MovieEntity> nowPlayingMovies;
  final List<MovieEntity> savedMovies;

  MovieListUpdatedState(
      this.trendingMovies, this.nowPlayingMovies, this.savedMovies);
}
