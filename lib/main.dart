import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dialed_in/providers/coffee_provider.dart';
import 'screens/bean_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CoffeeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Dialed In',
          debugShowCheckedModeBanner: false,
          themeMode: provider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFEFF1F1), // Light Grey
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF253ABD), // Primary Blue
              brightness: Brightness.light,
              primary: const Color(0xFF253ABD),
              secondary: const Color(0xFFE5E5EA), // Light Grey for elements
              surface: const Color(0xFFFFFFFF), // White for cards
              onPrimary: const Color(0xFFFFFFFF),
              onSurface: const Color(0xFF000000),
            ),
            textTheme: _buildTextTheme(Brightness.light),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFFEFF1F1),
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF253ABD),
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF000000), // Black
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF9F0A), // Technical Orange
              brightness: Brightness.dark,
              primary: const Color(0xFFFF9F0A),
              secondary: const Color(0xFF3A3A3C), // Dark Grey for elements
              surface: const Color(0xFF1C1C1E), // Slightly lighter grey for cards
              onPrimary: const Color(0xFF000000),
              onSurface: const Color(0xFFFFFFFF),
            ),
            textTheme: _buildTextTheme(Brightness.dark),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF000000),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFFF9F0A),
              foregroundColor: Colors.black,
            ),
          ),
          home: const BeanListScreen(),
        );
      },
    );
  }

  TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark ? Colors.white : Colors.black;
    final secondaryColor = brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 16,
        color: secondaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 14,
        color: secondaryColor,
      ),
    );
  }
}
