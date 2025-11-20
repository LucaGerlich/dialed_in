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
          scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Grey
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF212121), // Dark Grey/Black
            primary: const Color(0xFF212121),
            secondary: const Color(0xFF757575), // Grey
            surface: const Color(0xFFFFFFFF), // White
            onPrimary: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF212121),
          ),
          textTheme: TextTheme(
            displayLarge: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
            displayMedium: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
            titleLarge: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
            ),
            titleMedium: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
            ),
            bodyLarge: GoogleFonts.lato(
              fontSize: 16,
              color: const Color(0xFF212121),
            ),
            bodyMedium: GoogleFonts.lato(
              fontSize: 14,
              color: const Color(0xFF212121),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFF5F5F5),
            foregroundColor: const Color(0xFF212121),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF212121),
            foregroundColor: Colors.white,
          ),
        ),
        home: const BeanListScreen(),
      ),
    );
  }
}
