import 'package:path2degree/model/contenuto.dart';

class Materiale extends Contenuto {
  final String path;

  const Materiale({required super.nome, required this.path});

  @override
  Map<String, Object?> toMap() {
    return {'nome': nome, 'path': path};
  }

  @override
  Materiale fromMap(Map<String, Object?> map) {
    return Materiale(nome: map['nome'] as String, path: map['path'] as String);
  }

  @override
  String toString() {
    return 'Materiale { nome: $nome, path: $path }';
  }
}
