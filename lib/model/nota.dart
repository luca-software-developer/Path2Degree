import 'package:path2degree/model/contenuto.dart';

class Nota extends Contenuto {
  final String testo;

  const Nota({required super.nome, required this.testo});

  @override
  Map<String, Object?> toMap() {
    return {'nome': nome, 'testo': testo};
  }

  @override
  Nota fromMap(Map<String, Object?> map) {
    return Nota(nome: map['nome'] as String, testo: map['testo'] as String);
  }

  @override
  String toString() {
    return 'Nota { nome: $nome, testo: $testo }';
  }
}
