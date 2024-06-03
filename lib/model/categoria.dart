import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

/// La classe Categoria rappresenta una categoria di esami
/// a cui è associato un nome.
class Categoria {
  /// Nome della categoria.
  final String nome;

  /// Costruttore.
  const Categoria({required this.nome});

  /// Converte la categoria in una mappa.
  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  /// Costruisce un oggetto Categoria a partire da una mappa.
  Categoria fromMap(Map<String, Object?> map) {
    return Categoria(nome: map['nome'] as String);
  }

  /// Restituisce la lista delle categorie.
  static Future<List<Categoria>> getCategorie(BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('categoria');
    return rows.map((row) => Categoria(nome: row['nome'] as String)).toList();
  }

  /// Restituisce la categoria rappresentata come stringa.
  @override
  String toString() {
    return 'Categoria { nome: $nome }';
  }
}
