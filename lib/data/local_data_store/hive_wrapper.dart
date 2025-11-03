import 'package:findmyshow/constants/hive_keys.dart';
import 'package:findmyshow/data/models/movie.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDataStore {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    await Hive.initFlutter();
    await Hive.openBox(savedMovies);
    await Hive.openBox(baseTrendingMoviesBoxName);
    await Hive.openBox(baseNowPlayingMoviesBoxName);
  }

  Future<void> saveMovie(Movie movie) async {
    final box = await Hive.openBox(savedMovies);
    await box.put(movie.id, movie.toJson());
  }

  Future<void> saveBaseTrendingMovie(List<Movie> movie) async {
    final box = await Hive.openBox(baseTrendingMoviesBoxName);
    await box.clear();
    for (var m in movie) {
      await box.put(m.id, m.toJson());
    }
  }

  Future<void> saveBaseNowPlayingMovie(List<Movie> movie) async {
    final box = await Hive.openBox(baseNowPlayingMoviesBoxName);
    await box.clear();
    for (var m in movie) {
      await box.put(m.id, m.toJson());
    }
  }

  Future<List<Movie>> fetchAllSavedMovies() async {
    final box = await Hive.openBox(savedMovies);
    final List<Movie> allMovies = [];

    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        allMovies.add(Movie.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return allMovies;
  }

  Future<List<Movie>> fetchBaseTrendingMovies() async {
    final box = await Hive.openBox(baseTrendingMoviesBoxName);
    final List<Movie> allMovies = [];

    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        allMovies.add(Movie.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return allMovies;
  }

  Future<List<Movie>> fetchBaseNowPlayingMovies() async {
    final box = await Hive.openBox(baseNowPlayingMoviesBoxName);
    final List<Movie> allMovies = [];

    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        allMovies.add(Movie.fromJson(Map<String, dynamic>.from(value)));
      }
    }

    return allMovies;
  }

  Future<void> deleteSavedMovie(int id) async {
    final box = await Hive.openBox(savedMovies);
    await box.delete(id);
  }
}
