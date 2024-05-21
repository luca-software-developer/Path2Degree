import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/categoria.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';

class Statistiche extends StatefulWidget {
  const Statistiche({super.key});

  @override
  State<Statistiche> createState() => _StatisticheState();
}

class _StatisticheState extends State<Statistiche> {
  final _formKey = GlobalKey<FormState>();
  List<Categoria> _categorie = [];
  Categoria? _categoria;

  Future<String> _getVotoMassimo() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    List<int> voti = rows.map((row) {
      int voto = row['voto'] as int;
      bool lode = (row['lode'] as int) == 1;
      if (lode) {
        voto++;
      }
      return voto;
    }).toList();
    if (voti.isEmpty) {
      return '0';
    }
    int max = voti[0];
    for (final voto in voti) {
      if (voto > max) {
        max = voto;
      }
    }
    if (max == 31) {
      return '30L';
    }
    return max.toString();
  }

  Future<String> _getVotoMinimo() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    List<int> voti = rows.map((row) {
      int voto = row['voto'] as int;
      bool lode = (row['lode'] as int) == 1;
      if (lode) {
        voto++;
      }
      return voto;
    }).toList();
    if (voti.isEmpty) {
      return '0';
    }
    int min = voti[0];
    for (final voto in voti) {
      if (voto < min) {
        min = voto;
      }
    }
    if (min == 31) {
      return '30L';
    }
    return min.toString();
  }

  Future<String> _getMediaPonderata() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    double mediaPonderata = 0;
    int sommaCFU = 0;
    for (final row in rows) {
      int voto = row['voto'] as int;
      int cfu = row['cfu'] as int;
      mediaPonderata += voto * cfu;
      sommaCFU += cfu;
    }
    mediaPonderata /= sommaCFU;
    return mediaPonderata.toStringAsFixed(1);
  }

  Future<String> _getMediaAritmetica() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    double mediaAritmetica = 0;
    for (final row in rows) {
      int voto = row['voto'] as int;
      mediaAritmetica += voto;
    }
    mediaAritmetica /= rows.length;
    return mediaAritmetica.toStringAsFixed(1);
  }

  Future<String> _getVotoLaurea() async {
    return (double.parse(await _getMediaPonderata()) * 4.1 - 7.8)
        .round()
        .clamp(0, 110)
        .toString();
  }

  Future<List<Esame>> _getTop3() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame',
        where: 'voto IS NOT NULL', orderBy: 'voto DESC, lode DESC', limit: 3);
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  Future<List<Map<String, String>>> _getMediaPerCategoria() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.rawQuery(
        "SELECT A.categoria AS categoria, AVG(E.voto) AS votoMedio FROM esame AS E JOIN appartenenza AS A ON (E.nome = A.esame) GROUP BY A.categoria");
    return rows
        .map((row) => {
              'categoria': row['categoria'] as String,
              'votoMedio': (row['votoMedio'] as double).toString()
            })
        .toList();
  }

  Future<List<Categoria>> _getCategorie() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('categoria');
    return rows.map((row) => Categoria(nome: row['nome'] as String)).toList();
  }

  @override
  void initState() {
    super.initState();
    _getCategorie().then((categorie) => setState(() => _categorie = categorie));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            isScrollable: true,
            dividerHeight: 0,
            tabAlignment: TabAlignment.start,
            splashFactory: NoSplash.splashFactory,
            labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
            unselectedLabelStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(
                    letterSpacing: 0.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
            indicator: const BoxDecoration(),
            tabs: const [
              Tab(
                text: 'At a glance',
              ),
              Tab(
                text: 'Grafici per categoria',
              ),
            ],
          ),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 618,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                        future: _getVotoMassimo(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text(
                                              '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                snapshot.error.toString());
                                          } else {
                                            return Text(
                                              snapshot.data!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          }
                                        }),
                                    Text(
                                      'Voto massimo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              letterSpacing: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 382,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                        future: _getVotoMinimo(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text(
                                              '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                snapshot.error.toString());
                                          } else {
                                            return Text(
                                              snapshot.data!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          }
                                        }),
                                    Text(
                                      'Voto minimo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              letterSpacing: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 382,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                        future: _getVotoLaurea(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text(
                                              '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                snapshot.error.toString());
                                          } else {
                                            return Text(
                                              snapshot.data!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            );
                                          }
                                        }),
                                    const Spacer(),
                                    Text(
                                      'Voto di laurea corrente',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              letterSpacing: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 618,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder(
                                            future: _getMediaPonderata(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text(
                                                  '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        fontSize: 35,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    snapshot.error.toString());
                                              } else {
                                                return Text(
                                                  snapshot.data!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        fontSize: 35,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                );
                                              }
                                            }),
                                        Text(
                                          'Media ponderata',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  letterSpacing: 0.5,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7)),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        FutureBuilder(
                                            future: _getMediaAritmetica(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text(
                                                  '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    snapshot.error.toString());
                                              } else {
                                                return Text(
                                                  snapshot.data!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                );
                                              }
                                            }),
                                        Text(
                                          'Media aritmetica',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  letterSpacing: 0.5,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top 3',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Opacity(
                          opacity: .5,
                          child: Text('Il meglio dalla tua carriera',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _getTop3(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return snapshot.data!.isEmpty
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
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.school_rounded,
                                                  color: Colors.white),
                                              title: Text(
                                                  snapshot.data![index].nome,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                              subtitle: Opacity(
                                                  opacity: .5,
                                                  child: Text(
                                                      '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                              color: Colors
                                                                  .white))),
                                              trailing: IntrinsicWidth(
                                                child: Text(
                                                  snapshot.data![index].voto
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          letterSpacing: 0.5,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface),
                                                ),
                                              ),
                                            )));
                                  },
                                );
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Media per categoria di esame',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Opacity(
                          opacity: .5,
                          child: Text(
                              'Utili per capire i tuoi punti di forza... e di debolezza',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _getMediaPerCategoria(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return snapshot.data!.isEmpty
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
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.category_rounded,
                                                  color: Colors.white),
                                              title: Text(
                                                  snapshot.data![index]
                                                      ['categoria']!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                              trailing: IntrinsicWidth(
                                                child: Text(
                                                  snapshot.data![index]
                                                          ['votoMedio']!
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          letterSpacing: 0.5,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface),
                                                ),
                                              ),
                                            )));
                                  },
                                );
                        }
                      }),
                  const SizedBox(
                    height: 80.0,
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DropdownButtonFormField<Categoria>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'Specificare la categoria.';
                                  }
                                  return null;
                                },
                                value: _categoria,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Categoria',
                                ),
                                onChanged: (Categoria? newValue) {
                                  setState(() {
                                    _categoria = newValue!;
                                  });
                                },
                                items: _categorie.map((value) {
                                  return DropdownMenuItem<Categoria>(
                                    value: value,
                                    child: Text(value.nome),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}
