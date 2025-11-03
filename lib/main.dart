import 'package:findmyshow/data/local_data_store/hive_wrapper.dart';
import 'package:findmyshow/presentation/homepage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final localDataStore = LocalDataStore();
  await localDataStore.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');

    // 1️⃣ Handle the home route
    if (uri.path == '/') {
      return MaterialPageRoute(builder: (_) => const MyHomePage());
    }

    // 2️⃣ Handle dynamic movie route: /movie/123
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'movie') {
      final movieId = uri.pathSegments[1];
      return MaterialPageRoute(
        builder: (_) => MyHomePage(movieId: movieId),
      );
    }

    // 3️⃣ Unknown route (404)
    return MaterialPageRoute(builder: (_) => const MyHomePage());
  }
}
