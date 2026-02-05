import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dialed_in/providers/coffee_provider.dart';
import 'screens/bean_list_screen.dart';
import 'screens/onboarding_screen.dart';

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
            scaffoldBackgroundColor: const Color(0xFFF5F1ED), // Warm cream background
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6F4E37), // Coffee brown
              brightness: Brightness.light,
              primary: const Color(0xFF6F4E37), // Coffee brown
              secondary: const Color(0xFFE5DDD5), // Warm light beige
              surface: const Color(0xFFFFFBF7), // Warm white for cards
              onPrimary: const Color(0xFFFFFFFF),
              onSurface: const Color(0xFF2B1F1A), // Dark brown text
              tertiary: const Color(0xFFD2691E), // Warm amber accent
            ),
            textTheme: _buildTextTheme(Brightness.light),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFFF5F1ED),
              foregroundColor: const Color(0xFF2B1F1A),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B1F1A),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF6F4E37), // Coffee brown
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF000000), // Black
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD2691E), // Warm amber (chocolate)
              brightness: Brightness.dark,
              primary: const Color(0xFFD2691E), // Warm amber
              secondary: const Color(0xFF3A3A3C), // Dark Grey for elements
              surface: const Color(0xFF1C1C1E), // Slightly lighter grey for cards
              onPrimary: const Color(0xFF000000),
              onSurface: const Color(0xFFFFFFFF),
              tertiary: const Color(0xFFFF9F0A), // Keep technical orange as accent
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
              backgroundColor: Color(0xFFD2691E), // Warm amber
              foregroundColor: Colors.white,
            ),
          ),
          home: const AppHome(),
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

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        // Show loading indicator while data is being loaded
        if (provider.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        // Show onboarding if not completed
        if (!provider.hasCompletedOnboarding) {
          return OnboardingScreen(
            onComplete: () async {
              await provider.completeOnboarding();
            },
          );
        }

        // Show main app
        return const BeanListScreen();
      },
    );
  }
}
