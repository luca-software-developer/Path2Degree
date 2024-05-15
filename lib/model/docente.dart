class Docente {
  final int codice;
  final String nome;
  final String cognome;

  const Docente(
      {required this.codice, required this.nome, required this.cognome});

  Map<String, Object?> toMap() {
    return {'codice': codice, 'nome': nome, 'cognome': cognome};
  }

  Docente fromMap(Map<String, Object?> map) {
    return Docente(
        codice: map['codice'] as int,
        nome: map['nome'] as String,
        cognome: map['cognome'] as String);
  }

  @override
  String toString() {
    return 'Docente { codice: $codice, nome: $nome, cognome: $cognome }';
  }
}
