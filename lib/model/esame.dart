import 'package:path2degree/model/tipologia.dart';

class Esame {
  final String nome;
  final int cfu;
  final DateTime dataOra;
  final Tipologia tipologia;
  final int voto;

  const Esame(
      {required this.nome,
      required this.cfu,
      required this.dataOra,
      required this.tipologia,
      required this.voto});

  Map<String, Object?> toMap() {
    return {
      'nome': nome,
      'cfu': cfu,
      'dataOra': dataOra,
      'tipologia': tipologia,
      'voto': voto
    };
  }

  Esame fromMap(Map<String, Object?> map) {
    return Esame(
        nome: map['nome'] as String,
        cfu: map['cfu'] as int,
        dataOra: map['dataOra'] as DateTime,
        tipologia: map['tipologia'] as Tipologia,
        voto: map['voto'] as int);
  }

  @override
  String toString() {
    return 'Esame { nome: $nome, cfu: $cfu, dataOra: $dataOra, tipologia: $tipologia, voto: $voto }';
  }
}
