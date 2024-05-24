import 'package:flutter/material.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/pages/contenuto_diario.dart';
import 'package:path2degree/pages/add_diario.dart';
import 'package:provider/provider.dart';

class Diari extends StatefulWidget {
  const Diari({super.key});

  @override
  State<Diari> createState() => _DiariState();
}

class _DiariState extends State<Diari> {
  Future<List<Diario>> _getDiari() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('diario');
    return rows.map((row) => Diario(nome: row['nome'] as String)).toList();
  }

  Future<String> _getEsame(Diario diario) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows =
        await database.query('esame', where: "diario = '${diario.nome}'");
    if (rows.isEmpty) {
      return 'Non associato';
    }
    return Esame.fromMap(rows[0]).nome;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getDiari(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Errore'),
                  content: Text(snapshot.error.toString()),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return Container();
          } else {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: snapshot.data!.isEmpty
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('Nessun elemento'),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.book_rounded,
                                          color: Colors.white),
                                      title: Text(snapshot.data![index].nome,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                      subtitle: Opacity(
                                          opacity: .5,
                                          child: FutureBuilder(
                                              future: _getEsame(
                                                  snapshot.data![index]),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container();
                                                } else if (snapshot.hasError) {
                                                  return Text(snapshot.error
                                                      .toString());
                                                } else {
                                                  return Text(snapshot.data!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                              color: Colors
                                                                  .white));
                                                }
                                              })),
                                      trailing: IntrinsicWidth(
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (_) =>
                                                          ContenutoDiario(
                                                              diario: snapshot
                                                                  .data![index]
                                                                  .nome),
                                                    )),
                                                icon: const Icon(
                                                    Icons.edit_rounded)),
                                            IconButton(
                                                onPressed: () {
                                                  Provider.of<DatabaseProvider>(
                                                          context,
                                                          listen: false)
                                                      .database
                                                      .then((database) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Elimina diario'),
                                                            content: Text(
                                                                'Sei sicuro di voler eliminare il diario "${snapshot.data![index].nome}"'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        'Sì'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  database.delete(
                                                                      'diario',
                                                                      where:
                                                                          "nome = '${snapshot.data![index].nome}'");
                                                                  setState(
                                                                      () {});
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        'No'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.delete_rounded)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddDiario()));
                  setState(() {});
                },
                child: const Icon(Icons.add_rounded),
              ),
            );
          }
        });
  }
}
