import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/providers/shared_preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path2degree/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  if (!prefs.containsKey('dataPromemoria') ||
      DateTime.parse(prefs.getString('dataPromemoria')!)
          .isBefore(DateTime.now())) {
    prefs.setString(
        'dataPromemoria', today.add(const Duration(days: 7)).toIso8601String());
  }
  initializeDateFormatting()
      .then((_) => runApp(Path2Degree(savedThemeMode: savedThemeMode)));
}

class Path2Degree extends StatelessWidget {
  Path2Degree({super.key, this.savedThemeMode});

  static const String title = 'Path2Degree';

  final AdaptiveThemeMode? savedThemeMode;
  final TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.caveat(),
      displayMedium: GoogleFonts.caveat(fontSize: 40),
      displaySmall: GoogleFonts.caveat(fontSize: 30),
      titleMedium: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
      titleSmall: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15),
      bodyLarge: GoogleFonts.lato(),
      bodyMedium: GoogleFonts.lato());

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => SharedPreferencesProvider()),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          textTheme: textTheme,
          brightness: Brightness.light,
        ),
        dark: ThemeData(
          useMaterial3: true,
          textTheme: textTheme,
          brightness: Brightness.dark,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          title: title,
          theme: theme,
          darkTheme: darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: const [Locale('it')],
          debugShowCheckedModeBanner: false,
          home: const Home(),
        ),
      ),
    );
  }
}
