class Luogo {
  final String nome;

  const Luogo({required this.nome});

  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  Luogo fromMap(Map<String, Object?> map) {
    return Luogo(nome: map['nome'] as String);
  }

  @override
  String toString() {
    return 'Luogo { nome: $nome }';
  }
}
