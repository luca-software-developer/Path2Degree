class Categoria {
  final String nome;

  const Categoria({required this.nome});

  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  Categoria fromMap(Map<String, Object?> map) {
    return Categoria(nome: map['nome'] as String);
  }

  @override
  String toString() {
    return 'Categoria { nome: $nome }';
  }
}
