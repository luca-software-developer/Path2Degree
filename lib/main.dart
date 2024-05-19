import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/providers/shared_preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path2degree/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  if (!prefs.containsKey('dataPromemoria')) {
    prefs.setString(
        'dataPromemoria', today.add(const Duration(days: 7)).toIso8601String());
  }
  initializeDateFormatting().then((_) => runApp(const Path2Degree()));
}

class Path2Degree extends StatelessWidget {
  const Path2Degree({super.key});

  static const String title = 'Path2Degree';
  static const String slogan = 'Organize your exams';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => SharedPreferencesProvider()),
      ],
      child: MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                const ColorScheme.dark().copyWith(onPrimary: Colors.white),
            textTheme: TextTheme(
                displayLarge: GoogleFonts.caveat(),
                displayMedium: GoogleFonts.caveat(fontSize: 40),
                displaySmall: GoogleFonts.caveat(fontSize: 30),
                titleMedium:
                    GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
                titleSmall: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xbbffffff)),
                bodyLarge: GoogleFonts.lato(),
                bodyMedium: GoogleFonts.lato())),
        home: const Home(),
      ),
    );
  }
}
