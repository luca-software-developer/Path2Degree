import 'package:flutter/material.dart';
import 'package:path2degree/model/appunto.dart';
import 'package:path2degree/model/risorsa.dart';
import 'package:path2degree/pages/add_risorsa.dart';
import 'package:path2degree/pages/edit_appunto.dart';
import 'package:path2degree/pages/edit_risorsa.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/pages/add_appunto.dart';
import 'package:provider/provider.dart';
import 'package:path2degree/widgets/action_button.dart';
import 'package:path2degree/widgets/expandable_fab.dart';
import 'package:open_file_plus/open_file_plus.dart';

class ContenutoDiario extends StatefulWidget {
  const ContenutoDiario({super.key, required this.diario});

  final String diario;

  @override
  State<ContenutoDiario> createState() => _ContenutoDiarioState();
}

class _ContenutoDiarioState extends State<ContenutoDiario> {
  Future<List<Appunto>> _getAppunti() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows =
        await database.query('appunto', where: "diario = '${widget.diario}'");
    return rows
        .map((row) => Appunto(
            nome: row['nome'] as String,
            testo: row['testo'] as String,
            diario: row['diario'] as String))
        .toList();
  }

  Future<List<Risorsa>> _getRisorse() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows =
        await database.query('risorsa', where: "diario = '${widget.diario}'");
    return rows
        .map((row) => Risorsa(
            nome: row['nome'] as String,
            path: row['path'] as String,
            diario: row['diario'] as String))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.diario,
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                children: <Widget>[
                  Text('Appunti',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            FutureBuilder(
                future: _getAppunti(),
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
                                      leading: const Icon(Icons.note_rounded,
                                          color: Colors.white),
                                      title: Text(snapshot.data![index].nome,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                      trailing: IntrinsicWidth(
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (_) =>
                                                            EditAppunto(
                                                                nome: snapshot
                                                                    .data![
                                                                        index]
                                                                    .nome))),
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
                                                                'Elimina appunto'),
                                                            content: Text(
                                                                'Sei sicuro di voler eliminare il appunto "${snapshot.data![index].nome}"'),
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
                                                                      'appunto',
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
                    );
                  }
                }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Column(
                children: <Widget>[
                  Text('Risorse',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            FutureBuilder(
                future: _getRisorse(),
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
                                    child: GestureDetector(
                                      onTap: () {
                                        OpenFile.open(
                                            snapshot.data![index].path);
                                      },
                                      child: ListTile(
                                        leading: const Icon(Icons.note_rounded,
                                            color: Colors.white),
                                        title: Text(snapshot.data![index].nome,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                        trailing: IntrinsicWidth(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .push(MaterialPageRoute(
                                                          builder: (_) =>
                                                              EditRisorsa(
                                                                nome: snapshot
                                                                    .data![
                                                                        index]
                                                                    .nome,
                                                                diario: widget
                                                                    .diario,
                                                              ))),
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
                                                                  'Elimina risorsa'),
                                                              content: Text(
                                                                  'Sei sicuro di voler eliminare la risorsa "${snapshot.data![index].nome}"'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                          'Sì'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    database.delete(
                                                                        'risorsa',
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
                                                                  onPressed:
                                                                      () {
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
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddAppunto(diario: widget.diario)));
              setState(() {});
            },
            icon: const Icon(Icons.note_rounded),
          ),
          ActionButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddRisorsa(diario: widget.diario)));
              setState(() {});
            },
            icon: const Icon(Icons.attach_file),
          ),
        ],
      ),
    );
  }
}
