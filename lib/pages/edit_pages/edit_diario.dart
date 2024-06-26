import 'package:flutter/material.dart';
import 'package:path2degree/model/appunto.dart';
import 'package:path2degree/model/risorsa.dart';
import 'package:path2degree/pages/add_pages/add_risorsa.dart';
import 'package:path2degree/pages/edit_pages/edit_appunto.dart';
import 'package:path2degree/pages/edit_pages/edit_risorsa.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/pages/add_pages/add_appunto.dart';
import 'package:provider/provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class EditDiario extends StatefulWidget {
  const EditDiario({super.key, required this.diario});

  final String diario;

  @override
  State<EditDiario> createState() => _EditDiarioState();
}

class _EditDiarioState extends State<EditDiario> {
  final _key = GlobalKey<ExpandableFabState>();
  final _controller = TextEditingController();
  List<Appunto> _appunti = [];
  List<Risorsa> _risorse = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.diario,
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: 'Cerca appunti e risorse...',
                      prefixIcon: Icon(Icons.search_rounded)),
                  onChanged: (value) => setState(() {}),
                ),
              ),
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
                  future: Appunto.getAppunti(context, widget.diario),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      _appunti = snapshot.data!;
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
                                                  Icons.note_rounded),
                                              title: Text(
                                                  snapshot.data![index].nome,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              trailing: IntrinsicWidth(
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () => Navigator
                                                                .of(context)
                                                            .push(MaterialPageRoute(
                                                                builder: (_) => EditAppunto(
                                                                    nome: snapshot
                                                                        .data![
                                                                            index]
                                                                        .nome,
                                                                    appunti:
                                                                        snapshot
                                                                            .data!)))
                                                            .then((value) =>
                                                                setState(
                                                                    () {})),
                                                        icon: const Icon(Icons
                                                            .edit_rounded)),
                                                    IconButton(
                                                        onPressed: () {
                                                          Provider.of<DatabaseProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .database
                                                              .then((database) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Elimina appunto'),
                                                                    content: Text(
                                                                        'Sei sicuro di voler eliminare il appunto "${snapshot.data![index].nome}"'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'Sì'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          database.delete(
                                                                              'appunto',
                                                                              where: "nome = '${snapshot.data![index].nome}'");
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'No'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
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
                  future: Risorsa.getRisorse(context, widget.diario),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      _risorse = snapshot.data!;
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
                                                  Icons.note_rounded),
                                              title: Text(
                                                  snapshot.data![index].nome,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              trailing: IntrinsicWidth(
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () =>
                                                            OpenFile.open(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .path),
                                                        icon: const Icon(Icons
                                                            .open_in_new_rounded)),
                                                    IconButton(
                                                        onPressed: () => Navigator
                                                                .of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        EditRisorsa(
                                                                          nome: snapshot
                                                                              .data![index]
                                                                              .nome,
                                                                          diario:
                                                                              widget.diario,
                                                                          risorse:
                                                                              snapshot.data!,
                                                                        )))
                                                            .then((value) =>
                                                                setState(
                                                                    () {})),
                                                        icon: const Icon(Icons
                                                            .edit_rounded)),
                                                    IconButton(
                                                        onPressed: () {
                                                          Provider.of<DatabaseProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .database
                                                              .then((database) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Elimina risorsa'),
                                                                    content: Text(
                                                                        'Sei sicuro di voler eliminare la risorsa "${snapshot.data![index].nome}"'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'Sì'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          database.delete(
                                                                              'risorsa',
                                                                              where: "nome = '${snapshot.data![index].nome}'");
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'No'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
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
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        openButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.add_rounded),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          fabSize: ExpandableFabSize.small,
          child: const Icon(Icons.close_rounded),
        ),
        distance: 112,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            shape: const CircleBorder(),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddAppunto(
                        diario: widget.diario,
                        appunti: _appunti,
                      )));
              setState(() {});
            },
            child: const Icon(Icons.note_rounded),
          ),
          FloatingActionButton.small(
            heroTag: null,
            shape: const CircleBorder(),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddRisorsa(
                        diario: widget.diario,
                        risorse: _risorse,
                      )));
              setState(() {});
            },
            child: const Icon(Icons.attach_file),
          ),
        ],
      ),
    );
  }
}
