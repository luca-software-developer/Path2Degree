import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/pages/edit_pages/edit_diario.dart';
import 'package:path2degree/pages/add_pages/add_diario.dart';
import 'package:provider/provider.dart';

class Diari extends StatefulWidget {
  const Diari({super.key});

  @override
  State<Diari> createState() => _DiariState();
}

class _DiariState extends State<Diari> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, mode, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'Cerca diari...',
                        prefixIcon: Icon(Icons.search_rounded)),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                FutureBuilder(
                    future: Diario.getDiari(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return Padding(
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
                                    return _controller.text.trim().isNotEmpty &&
                                            !snapshot.data![index].nome
                                                .trim()
                                                .toLowerCase()
                                                .contains(_controller.text
                                                    .trim()
                                                    .toLowerCase())
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 16, 16, 0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  width: 1,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: const Icon(
                                                  Icons.book_rounded,
                                                ),
                                                title: Text(
                                                    snapshot.data![index].nome,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AdaptiveTheme.of(
                                                                            context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                subtitle: Opacity(
                                                    opacity: .5,
                                                    child: FutureBuilder(
                                                        future: Diario.getEsame(
                                                            context,
                                                            snapshot
                                                                .data![index]),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Container();
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(snapshot
                                                                .error
                                                                .toString());
                                                          } else {
                                                            return Text(
                                                                snapshot.data!,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium);
                                                          }
                                                        })),
                                                trailing: IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                      MaterialPageRoute(
                                                                builder: (_) => EditDiario(
                                                                    diario: snapshot
                                                                        .data![
                                                                            index]
                                                                        .nome),
                                                              )),
                                                          icon: const Icon(Icons
                                                              .edit_rounded)),
                                                      IconButton(
                                                          onPressed: () {
                                                            Provider.of<DatabaseProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .database
                                                                .then(
                                                                    (database) {
                                                              database
                                                                  .query(
                                                                      'esame',
                                                                      where:
                                                                          "diario = '${snapshot.data![index].nome}'")
                                                                  .then((rows) {
                                                                if (rows
                                                                    .isEmpty) {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Elimina diario'),
                                                                          content:
                                                                              Text('Sei sicuro di voler eliminare il diario "${snapshot.data![index].nome}"'),
                                                                          actions: <Widget>[
                                                                            TextButton(
                                                                              child: const Text('Sì'),
                                                                              onPressed: () async {
                                                                                Navigator.of(context).pop();
                                                                                await database.delete('diario', where: "nome = '${snapshot.data![index].nome}'");
                                                                                await database.delete('appunto', where: "diario = '${snapshot.data![index].nome}'");
                                                                                await database.delete('risorsa', where: "diario = '${snapshot.data![index].nome}'");
                                                                                setState(() {});
                                                                              },
                                                                            ),
                                                                            TextButton(
                                                                              child: const Text('No'),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                } else {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Diario in uso'),
                                                                          content:
                                                                              const Text('Questo diario è associato a un esame. Non puoi eliminarlo!'),
                                                                          actions: <Widget>[
                                                                            TextButton(
                                                                              child: const Text('OK'),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                }
                                                              });
                                                            });
                                                          },
                                                          icon: const Icon(Icons
                                                              .delete_rounded)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                        );
                      }
                    }),
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FutureBuilder(
                    future: Diario.getDiari(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return AddDiario(diari: snapshot.data!);
                      }
                    }),
              ));
              setState(() {});
            },
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}
