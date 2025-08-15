import 'package:flutter/material.dart';
import 'package:visiontxt/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme(),
      routerConfig: router,
    );
  }

  ThemeData theme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      useMaterial3: true,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}