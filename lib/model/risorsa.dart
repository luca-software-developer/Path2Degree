import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// La classe Risorsa rappresenta una risorsa contenuta in un diario.
class Risorsa {
  /// Nome della risorsa.
  final String nome;

  /// Path della risorsa.
  final String path;

  /// Diario in cui la risorsa è contenuta.
  final String diario;

  /// Costruttore.
  const Risorsa({required this.nome, required this.path, required this.diario});

  /// Converte la risorsa in una mappa.
  Map<String, Object?> toMap() {
    return {'nome': nome, 'path': path, 'diario': diario};
  }

  /// Costruisce una risorsa a partire da una mappa.
  factory Risorsa.fromMap(Map<String, Object?> map) {
    return Risorsa(
        nome: map['nome'] as String,
        path: map['path'] as String,
        diario: map['diario'] as String);
  }

  /// Restituisce la lista delle risorse contenute nel diario specificato.
  static Future<List<Risorsa>> getRisorse(
      BuildContext context, String diario) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('risorsa', where: "diario = '$diario'");
    return rows
        .map((row) => Risorsa(
            nome: row['nome'] as String,
            path: row['path'] as String,
            diario: row['diario'] as String))
        .toList();
  }

  /// Dato il nome della risorsa, restituisce il path.
  static Future<String> getPath(BuildContext context, String nome) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('risorsa', where: "nome = '$nome'");
    return rows[0]['path'] as String;
  }

  /// Consente di scegliere un file e ne restituisce il path.
  static Future<String?> showFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }

  /// Restituisce la risorsa rappresentata come stringa.
  @override
  String toString() {
    return 'Risorsa { nome: $nome, path: $path, diario: $diario }';
  }
}
