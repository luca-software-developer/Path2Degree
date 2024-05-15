class Diario {
  final String nome;

  const Diario({required this.nome});

  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  Diario fromMap(Map<String, Object?> map) {
    return Diario(nome: map['nome'] as String);
  }

  @override
  String toString() {
    return 'Luogo { nome: $nome }';
  }
}
