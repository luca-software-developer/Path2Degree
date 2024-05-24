class Risorsa {
  final String nome;
  final String path;
  final String diario;

  const Risorsa({required this.nome, required this.path, required this.diario});

  Map<String, Object?> toMap() {
    return {'nome': nome, 'path': path, 'diario': diario};
  }

  factory Risorsa.fromMap(Map<String, Object?> map) {
    return Risorsa(
        nome: map['nome'] as String,
        path: map['path'] as String,
        diario: map['diario'] as String);
  }

  @override
  String toString() {
    return 'Risorsa { nome: $nome, path: $path, diario: $diario }';
  }
}
