import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path2degree/screens/home.dart';

const String dbFileName = 'path2degree.db';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), dbFileName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    version: 1,
  );
  initializeDateFormatting().then((_) => runApp(const Path2Degree()));
}

class Path2Degree extends StatelessWidget {
  const Path2Degree({super.key});

  static const String title = 'Path2Degree';
  static const String slogan = 'Organize your exams';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(),
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
              bodyMedium: GoogleFonts.lato())),
      home: const Home(),
    );
  }
}
