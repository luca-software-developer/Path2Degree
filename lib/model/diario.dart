class Diario {
  final String nome;
  final String testo;

  const Diario({required this.nome, required this.testo});

  Map<String, Object?> toMap() {
    return {'nome': nome, 'testo': testo};
  }

  factory Diario.fromMap(Map<String, Object?> map) {
    return Diario(nome: map['nome'] as String, testo: map['testo'] as String);
  }

  @override
  String toString() {
    return 'Luogo { nome: $nome, testo: $testo }';
  }
}
