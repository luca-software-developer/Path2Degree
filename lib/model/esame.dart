import 'package:path2degree/model/tipologia.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/model/categoria.dart';

class Esame {
  final String nome;
  final String corsoDiStudi;
  final int cfu;
  final DateTime dataOra;
  final String luogo;
  final Tipologia tipologia;
  final String docente;
  final int voto;
  final bool lode;
  final List<Categoria> categorie;
  final Diario diario;

  const Esame({
    required this.nome,
    required this.corsoDiStudi,
    required this.cfu,
    required this.dataOra,
    required this.luogo,
    required this.tipologia,
    required this.docente,
    required this.voto,
    required this.lode,
    required this.categorie,
    required this.diario,
  });

  factory Esame.fromMap(Map<String, dynamic> map) {
    return Esame(
      nome: map['nome'] as String,
      corsoDiStudi: map['corsoDiStudi'] as String,
      cfu: map['cfu'] as int,
      dataOra: DateTime.parse(map['dataOra'] as String),
      luogo: map['luogo'] as String,
      tipologia: map['tipologia'] as Tipologia,
      docente: map['docente'] as String,
      voto: map['voto'] as int,
      lode: map['lode'] as bool,
      categorie: map['categorie'] as List<Categoria>,
      diario: map['diario'] as Diario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'corsoDiStudi': corsoDiStudi,
      'cfu': cfu,
      'dataOra': dataOra,
      'luogo': luogo,
      'tipologia': tipologia,
      'docente': docente,
      'voto': voto,
      'lode': lode,
      'categorie': categorie,
      'diario': diario,
    };
  }

  @override
  String toString() {
    return 'Esame { nome: $nome, corsoDiStudi: $corsoDiStudi, cfu: $cfu, dataOra: $dataOra, luogo: $luogo, tipologia: $tipologia, docente: $docente, voto: $voto, lode: $lode, diario: $diario, categorie: $categorie }';
  }
}
