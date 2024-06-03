import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

/// La classe Appunto rappresenta un appunto contenuto in un diario
/// e ha un nome, un testo e un diario di appartenenza.
class Appunto {
  /// Nome dell'appunto.
  final String nome;

  /// Contenuto dell'appunto.
  final String testo;

  /// Diario di appartenenza.
  final String diario;

  /// Costruttore.
  const Appunto(
      {required this.nome, required this.testo, required this.diario});

  /// Converte l'appunto in una mappa.
  Map<String, Object?> toMap() {
    return {'nome': nome, 'testo': testo, 'diario': diario};
  }

  /// Costruisce un oggetto Appunto a partire da una mappa.
  factory Appunto.fromMap(Map<String, Object?> map) {
    return Appunto(
        nome: map['nome'] as String,
        testo: map['testo'] as String,
        diario: map['diario'] as String);
  }

  /// Restituisce la lista degli appunti contenuti nel diario specificato.
  static Future<List<Appunto>> getAppunti(
      BuildContext context, String diario) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('appunto', where: "diario = '$diario'");
    return rows
        .map((row) => Appunto(
            nome: row['nome'] as String,
            testo: row['testo'] as String,
            diario: row['diario'] as String))
        .toList();
  }

  /// Restituisce il contenuto di un appunto.
  static Future<String> getTesto(BuildContext context, String nome) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('appunto', where: "nome = '$nome'");
    return rows[0]['testo'] as String;
  }

  /// Restituisce l'appunto rappresentato come stringa.
  @override
  String toString() {
    return 'Appunto { nome: $nome, testo: $testo, diario: $diario }';
  }
}
