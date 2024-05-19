import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/pages/add_esame.dart';
import 'package:path2degree/pages/edit_esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';

class Esami extends StatefulWidget {
  const Esami({super.key});

  @override
  State<Esami> createState() => _EsamiState();
}

class _EsamiState extends State<Esami> {
  Future<List<Esame>> _getEsamiInCorso() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NULL');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  Future<List<Esame>> _getEsamiSuperati() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NOT NULL');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                children: <Widget>[
                  Text('Esami in corso',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FutureBuilder(
                  future: _getEsamiInCorso(),
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
                      return Text(snapshot.error.toString());
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                leading: const Icon(Icons.school_rounded,
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
                                    child: Text(
                                        '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white))),
                                trailing: IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) => EditEsame(
                                                      nome: snapshot
                                                          .data![index].nome))),
                                          icon: const Icon(Icons.edit_rounded)),
                                      IconButton(
                                          onPressed: () {
                                            Provider.of<DatabaseProvider>(
                                                    context,
                                                    listen: false)
                                                .database
                                                .then((database) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Elimina esame'),
                                                      content: Text(
                                                          'Sei sicuro di voler eliminare l\'esame "${snapshot.data![index].nome}"'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              const Text('Sì'),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await database.delete(
                                                                'esame',
                                                                where:
                                                                    "nome = '${snapshot.data![index].nome}'");
                                                            await database.delete(
                                                                'appartenenza',
                                                                where:
                                                                    "esame = '${snapshot.data![index].nome}'");
                                                            await database
                                                                .rawDelete(
                                                                    "DELETE FROM categoria AS C WHERE NOT EXISTS (SELECT * FROM appartenenza AS A WHERE A.categoria = C.nome)");
                                                            setState(() {});
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              const Text('No'),
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
                                          icon:
                                              const Icon(Icons.delete_rounded)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                children: <Widget>[
                  Text('Esami superati',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FutureBuilder(
                  future: _getEsamiSuperati(),
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
                      return Text(snapshot.error.toString());
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                leading: const Icon(Icons.school_rounded,
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
                                    child: Text(
                                        '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white))),
                                trailing: IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) => EditEsame(
                                                      nome: snapshot
                                                          .data![index].nome))),
                                          icon: const Icon(Icons.edit_rounded)),
                                      IconButton(
                                          onPressed: () {
                                            Provider.of<DatabaseProvider>(
                                                    context,
                                                    listen: false)
                                                .database
                                                .then((database) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Elimina esame'),
                                                      content: Text(
                                                          'Sei sicuro di voler eliminare l\'esame "${snapshot.data![index].nome}"'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              const Text('Sì'),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await database.delete(
                                                                'esame',
                                                                where:
                                                                    "nome = '${snapshot.data![index].nome}'");
                                                            await database.delete(
                                                                'appartenenza',
                                                                where:
                                                                    "esame = '${snapshot.data![index].nome}'");
                                                            await database
                                                                .rawDelete(
                                                                    "DELETE FROM categoria AS C WHERE NOT EXISTS (SELECT * FROM appartenenza AS A WHERE A.categoria = C.nome)");
                                                            setState(() {});
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              const Text('No'),
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
                                          icon:
                                              const Icon(Icons.delete_rounded)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddEsame()))
            .then((_) => setState(() {})),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
