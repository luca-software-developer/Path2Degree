import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = 'path2degree.db';
const String dbAssetPath = 'assets/databases/path2degree.db';

class DatabaseProvider extends ChangeNotifier {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

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
}
