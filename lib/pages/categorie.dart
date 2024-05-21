import 'package:flutter/material.dart';
import 'package:path2degree/model/categoria.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';

class Categorie extends StatefulWidget {
  const Categorie({super.key});

  @override
  State<Categorie> createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  Future<List<Categoria>> _getCategorie() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('categoria');
    return rows.map((row) => Categoria(nome: row['nome'] as String)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCategorie(),
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
                                        leading: const Icon(
                                            Icons.category_rounded,
                                            color: Colors.white),
                                        title: Text(snapshot.data![index].nome,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white))),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
