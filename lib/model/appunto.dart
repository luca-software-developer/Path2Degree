class Appunto {
  final String nome;
  final String testo;
  final String diario;

  const Appunto({required this.nome,required this.testo,required this.diario});

  Map<String, Object?> toMap() {
    return {'nome': nome, 'testo': testo, 'diario': diario};
  }

  factory Appunto.fromMap(Map<String, Object?> map) {
    return Appunto(nome: map['nome'] as String, testo: map['testo'] as String, diario: map['diario'] as String);
  }

  @override
  String toString() {
    return 'Appunto { nome: $nome, testo: $testo, diario: $diario }';
  }
}
