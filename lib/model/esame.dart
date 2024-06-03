import 'package:flutter/material.dart';
import 'package:path2degree/model/tipologia.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

/// La classe Esame rappresenta un esame con tutte le informazioni ad esso
/// associate.
class Esame {
  /// Nome dell'esame.
  final String nome;

  /// Corso di studi di appartenenza.
  final String corsoDiStudi;

  /// Numero di CFU.
  final int cfu;

  /// Data e ora dell'esame.
  final DateTime dataOra;

  /// Luogo dell'esame.
  final String luogo;

  /// Tipologia di esame (scritto, orale, scritto e orale).
  final Tipologia tipologia;

  /// Nome del docente.
  final String docente;

  /// Voto dell'esame ed eventuale lode.
  final int? voto;
  final bool? lode;

  /// Diario associato.
  final String diario;

  /// Costruttore.
  const Esame({
    required this.nome,
    required this.corsoDiStudi,
    required this.cfu,
    required this.dataOra,
    required this.luogo,
    required this.tipologia,
    required this.docente,
    this.voto,
    this.lode,
    required this.diario,
  });

  /// Restituisce un oggetto Esame a partire dalla mappa specificata.
  static Esame fromMap(Map<String, dynamic> map) {
    return Esame(
      nome: map['nome'] as String,
      corsoDiStudi: map['corsodistudi'] as String,
      cfu: map['cfu'] as int,
      dataOra: DateTime.parse(map['dataora'] as String),
      luogo: map['luogo'] as String,
      tipologia: _tipologiaFromString(map['tipologia'] as String),
      docente: map['docente'] as String,
      voto: map['voto'] as int?,
      lode: (map['lode'] as int?) == 1,
      diario: map['diario'] as String,
    );
  }

  /// Restituisce l'elemento dell'enumerazione Tipologia corrispondente
  /// alla stringa fornita.
  static Tipologia _tipologiaFromString(String tipologiaAsString) {
    switch (tipologiaAsString) {
      case 'scritto':
        return Tipologia.scritto;
      case 'orale':
        return Tipologia.orale;
      case 'scrittoOrale':
        return Tipologia.scrittoOrale;
      default:
        throw Exception('$tipologiaAsString non è una tipologia.');
    }
  }

  /// Converte l'esame in una mappa.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'corsodistudi': corsoDiStudi,
      'cfu': cfu,
      'dataora': dataOra,
      'luogo': luogo,
      'tipologia': tipologia,
      'docente': docente,
      'voto': voto,
      'lode': lode,
      'diario': diario,
    };
  }

  /// Restituisce la lista di esami.
  static Future<List<Esame>> getEsami(BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('esame');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  /// Restituisce la lista di esami non sostenuti.
  static Future<List<Esame>> getEsamiNonSostenuti(BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('esame', where: 'voto IS NULL');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  /// Restituisce la lista di esami superati.
  static Future<List<Esame>> getEsamiSuperati(BuildContext context) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  /// Restituisce i primi tre esami (imminenti) entro una data fornita.
  static List<Esame> getEsamiPrimaDel(List<Esame> esami, DateTime data) {
    List<Esame> promemoria = [];
    for (final esame in esami) {
      if (esame.dataOra.isBefore(data)) {
        promemoria.add(esame);
      }
    }
    promemoria.sort((e1, e2) => e1.dataOra.compareTo(e2.dataOra));
    return promemoria.sublist(0, promemoria.length > 3 ? 3 : promemoria.length);
  }

  /// Restituisce le categorie dell'esame.
  static Future<List<String>> getCategorieEsame(
      BuildContext context, String nome) async {
    Database database = await DatabaseProvider.getDatabase(context);
    final rows = await database.query('appartenenza', where: "esame = '$nome'");
    return rows.map((row) => row['categoria'] as String).toList();
  }

  /// Restituisce l'esame rappresentato come stringa.
  @override
  String toString() {
    return 'Esame { nome: $nome, corsoDiStudi: $corsoDiStudi, cfu: $cfu, dataOra: $dataOra, luogo: $luogo, tipologia: $tipologia, docente: $docente, voto: $voto, lode: $lode, diario: $diario }';
  }
}
