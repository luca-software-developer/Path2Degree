import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/categoria.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/utils/chart_colors.dart';
import 'package:path2degree/widgets/chart.dart';
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
    if (rows.isEmpty) {
      return 0.toString();
    }
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
    if (rows.isEmpty) {
      return 0.toString();
    }
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
              'votoMedio':
                  ((row['votoMedio'] ?? 0.0) as double).toStringAsFixed(1)
            })
        .toList();
  }

  Future<List<Categoria>> _getCategorie() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('categoria', orderBy: 'nome');
    return rows.map((row) => Categoria(nome: row['nome'] as String)).toList();
  }

  Future<List<double>> _getEvoluzioneMediaPerCategoria(
      Categoria categoria) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.rawQuery(
        "SELECT * FROM esame AS E WHERE EXISTS (SELECT * FROM appartenenza AS A WHERE E.nome = A.esame AND A.categoria = '${categoria.nome}') ORDER BY E.dataOra");
    List<int> voti = [];
    List<double> evoluzioneMedia = [];
    for (final row in rows) {
      if (row['voto'] == null) {
        continue;
      }
      voti.add(row['voto'] as int);
      double media = 0;
      for (final voto in voti) {
        media += voto;
      }
      media /= voti.length;
      evoluzioneMedia.add(media);
    }
    return evoluzioneMedia;
  }

  Future<List<double>> _getEvoluzioneVotoMassimoPerCategoria(
      Categoria categoria) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.rawQuery(
        "SELECT * FROM esame AS E WHERE EXISTS (SELECT * FROM appartenenza AS A WHERE E.nome = A.esame AND A.categoria = '${categoria.nome}') ORDER BY E.dataOra");
    List<int> voti = [];
    List<double> evoluzioneVotoMassimo = [];
    for (final row in rows) {
      if (row['voto'] == null) {
        continue;
      }
      voti.add(row['voto'] as int);
      evoluzioneVotoMassimo.add(voti.reduce(max).toDouble());
    }
    return evoluzioneVotoMassimo;
  }

  Future<List<double>> _getEvoluzioneVotoMinimoPerCategoria(
      Categoria categoria) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.rawQuery(
        "SELECT * FROM esame AS E WHERE EXISTS (SELECT * FROM appartenenza AS A WHERE E.nome = A.esame AND A.categoria = '${categoria.nome}') ORDER BY E.dataOra");
    List<int> voti = [];
    List<double> evoluzioneVotoMinimo = [];
    for (final row in rows) {
      if (row['voto'] == null) {
        continue;
      }
      voti.add(row['voto'] as int);
      evoluzioneVotoMinimo.add(voti.reduce(min).toDouble());
    }
    return evoluzioneVotoMinimo;
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
                text: 'A colpo d\'occhio',
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
                          return Container();
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                width: 1,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.school_rounded),
                                              title: Text(
                                                  snapshot.data![index].nome,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              subtitle: Opacity(
                                                  opacity: .5,
                                                  child: Text(
                                                      '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium)),
                                              trailing: IntrinsicWidth(
                                                child: Text(
                                                  snapshot.data![index].voto
                                                          .toString() +
                                                      ((snapshot.data![index]
                                                                  .lode ??
                                                              false)
                                                          ? 'L'
                                                          : ''),
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
                          return Container();
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                width: 1,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.category_rounded),
                                              title: Text(
                                                  snapshot.data![index]
                                                      ['categoria']!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
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
                  _categoria == null
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Evoluzione della media',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: .5,
                                child: Text(
                                    'Stai migliorando in \'${_categoria?.nome}\'?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),

                            //

                            FutureBuilder(
                                future: _getEvoluzioneMediaPerCategoria(
                                    _categoria!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return Chart(
                                      voti: snapshot.data ?? [],
                                      colors: const [
                                        ChartColors.contentColorCyan,
                                        ChartColors.contentColorBlue,
                                      ],
                                    );
                                  }
                                }),

                            //

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Voto massimo per la categoria',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: .5,
                                child: Text(
                                    'I tuoi record in \'${_categoria?.nome}\'',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),

                            //

                            FutureBuilder(
                                future: _getEvoluzioneVotoMassimoPerCategoria(
                                    _categoria!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return Chart(
                                      voti: snapshot.data ?? [],
                                      colors: const [
                                        ChartColors.contentColorCyan,
                                        ChartColors.contentColorGreen,
                                      ],
                                    );
                                  }
                                }),

                            //

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Voto minimo per la categoria',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: .5,
                                child: Text(
                                    'Stiamo andando nella direzione giusta?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),

                            //

                            FutureBuilder(
                                future: _getEvoluzioneVotoMinimoPerCategoria(
                                    _categoria!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return Chart(
                                      voti: snapshot.data ?? [],
                                      colors: const [
                                        ChartColors.contentColorYellow,
                                        ChartColors.contentColorOrange,
                                      ],
                                    );
                                  }
                                }),

                            //
                          ],
                        ),
                ],
              ),
            ),
          ]),
        ));
  }
}
