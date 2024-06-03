import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = 'path2degree.db';
const String dbAssetPath = 'assets/databases/path2degree.db';

/// Il provider DatabaseProvider consente di gestire in modo centralizzato
/// ed efficiente l'accesso al database attraverso le varie schermate dell'app.
class DatabaseProvider extends ChangeNotifier {
  Database? _database;

  /// Restituisce l'oggetto Database.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inizializza il database e restituisce l'oggetto Database corrispondente.
  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), dbName);
      if (!(await databaseExists(path))) {
        final bytes = await rootBundle.load(dbAssetPath);
        await Directory(dirname(path)).create(recursive: true);
        await File(path).writeAsBytes(bytes.buffer.asInt8List());
      }
      return await openDatabase(path);
    } catch (e) {
      throw Exception('Impossibile inizializzare il database: $e');
    }
  }

  /// Restituisce il database dato il contesto.
  static Future<Database> getDatabase(BuildContext context) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    return database;
  }
}
