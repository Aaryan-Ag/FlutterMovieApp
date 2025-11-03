import 'package:dio/dio.dart';
import 'package:findmyshow/data/endpoint/movieEndpoint.dart';

class ApiClient {
  static const String apiKey = "f7e5085f270d4d798b167586bf6c0e2f";

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true)); // Optional
    return dio;
  }

  static MovieEndpoint createMovieEndpoint() {
    return MovieEndpoint(createDio());
  }
}
