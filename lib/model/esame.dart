import 'package:path2degree/model/tipologia.dart';

class Esame {
  final String nome;
  final String corsoDiStudi;
  final int cfu;
  final DateTime dataOra;
  final String luogo;
  final Tipologia tipologia;
  final String docente;
  final int? voto;
  final bool? lode;
  final String diario;

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

  @override
  String toString() {
    return 'Esame { nome: $nome, corsoDiStudi: $corsoDiStudi, cfu: $cfu, dataOra: $dataOra, luogo: $luogo, tipologia: $tipologia, docente: $docente, voto: $voto, lode: $lode, diario: $diario }';
  }
}
