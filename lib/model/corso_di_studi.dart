class CorsoDiStudi {
  final String nome;

  const CorsoDiStudi({required this.nome});

  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  CorsoDiStudi fromMap(Map<String, Object?> map) {
    return CorsoDiStudi(nome: map['nome'] as String);
  }

  @override
  String toString() {
    return 'CorsoDiStudi { nome: $nome }';
  }
}
