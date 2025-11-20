import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/coffee_provider.dart';
import 'screens/bean_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoffeeProvider()),
      ],
      child: MaterialApp(
        title: 'Dialed In',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
          textTheme: TextTheme(
            displayLarge: GoogleFonts.robotoMono(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: GoogleFonts.robotoMono(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.robotoMono(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            bodyLarge: GoogleFonts.robotoMono(
              fontSize: 16,
              color: Colors.white70,
            ),
            bodyMedium: GoogleFonts.robotoMono(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.robotoMono(
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
      ),
    );
  }
}
