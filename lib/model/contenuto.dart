class Contenuto {
  final String nome;

  const Contenuto({required this.nome});

  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  Contenuto fromMap(Map<String, Object?> map) {
    return Contenuto(nome: map['nome'] as String);
  }

  @override
  String toString() {
    return 'Contenuto { nome: $nome }';
  }
}
