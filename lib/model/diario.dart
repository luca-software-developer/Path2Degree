import 'package:flutter/material.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

/// La classe Diario rappresenta un diario associato ad un esame.
class Diario {
  /// Nome del diario.
  final String nome;

  /// Costruttore.
  const Diario({required this.nome});

  /// Converte il diario in una mappa.
  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  /// Costruisce un diario a partire da una mappa.
  factory Diario.fromMap(Map<String, Object?> map) {
    return Diario(nome: map['nome'] as String);
  }

  /// Restituisce la lista dei diari.
  static Future<List<Diario>> getDiari(BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('diario');
    return rows.map((row) => Diario(nome: row['nome'] as String)).toList();
  }

  /// Restituisce l'esame associato ad un determinato diario.
  static Future<String> getEsame(BuildContext context, Diario diario) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows =
        await database.query('esame', where: "diario = '${diario.nome}'");
    if (rows.isEmpty) {
      return 'Non associato';
    }
    return Esame.fromMap(rows[0]).nome;
  }

  /// Restituisce le righe della tabella diario che non sono associate
  /// a nessun esame a cui si aggiunge il diario specificato.
  static Future<List<Map<String, Object?>>> getDiariRiassegnabili(
      BuildContext context, String nome) async {
    Database database = await DatabaseProvider.getDatabase(context);
    return database.rawQuery('SELECT * FROM diario AS D '
        'WHERE nome = \'$nome\' '
        'OR NOT EXISTS (SELECT * FROM esame AS E WHERE E.diario = D.nome)');
  }

  /// Restituisce la lista dei diari non assegnati ad un esame.
  static Future<List<Map<String, Object?>>> getDiariAssegnabili(
      BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    return database.rawQuery('SELECT * FROM diario AS D '
        'WHERE NOT EXISTS (SELECT * FROM esame AS E WHERE E.diario = D.nome)');
  }

  /// Restituisce il diario rappresentato come stringa.
  @override
  String toString() {
    return 'Diario { nome: $nome }';
  }
}
