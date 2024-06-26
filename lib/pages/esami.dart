import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/pages/add_pages/add_esame.dart';
import 'package:path2degree/pages/edit_pages/edit_esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/utils/local_notification_service.dart';
import 'package:provider/provider.dart';

class Esami extends StatefulWidget {
  const Esami({super.key});

  @override
  State<Esami> createState() => _EsamiState();
}

class _EsamiState extends State<Esami> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                        hintText: 'Cerca esami...',
                        prefixIcon: Icon(Icons.search_rounded)),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Column(
                    children: <Widget>[
                      Text('Esami non ancora sostenuti',
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
                      future: Esame.getEsamiNonSostenuti(context),
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
                                                    Icons.school_rounded),
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
                                                    child: Text(
                                                        '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium)),
                                                trailing: IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () => Navigator
                                                                  .of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              EditEsame(
                                                                                nome: snapshot.data![index].nome,
                                                                                esame: snapshot.data![index],
                                                                                esami: snapshot.data!,
                                                                              )))
                                                              .then((_) =>
                                                                  setState(
                                                                    () {},
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
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Elimina esame'),
                                                                      content: Text(
                                                                          'Sei sicuro di voler eliminare l\'esame "${snapshot.data![index].nome}"'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Sì'),
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.of(context).pop();
                                                                            await database.delete('esame',
                                                                                where: "nome = '${snapshot.data![index].nome}'");
                                                                            await database.delete('appartenenza',
                                                                                where: "esame = '${snapshot.data![index].nome}'");
                                                                            await database.rawDelete("DELETE FROM categoria AS C "
                                                                                "WHERE NOT EXISTS ("
                                                                                "SELECT * FROM appartenenza AS A "
                                                                                "WHERE A.categoria = C.nome)");
                                                                            EsameNotificationService
                                                                                service =
                                                                                EsameNotificationService();
                                                                            await service.initialize();
                                                                            service.cancelExamNotification(snapshot.data![index].nome);
                                                                            setState(() {});
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('No'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
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
                      future: Esame.getEsamiSuperati(context),
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
                                                  Icons.school_rounded,
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
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Opacity(
                                                        opacity: .5,
                                                        child: Text(
                                                            '${DateFormat('dd/MM/yyyy').format(snapshot.data![index].dataOra)} — ${DateFormat('HH:mm').format(snapshot.data![index].dataOra)}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium)),
                                                    Row(
                                                      children: [
                                                        Text('Superato con ',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium),
                                                        Text(
                                                            snapshot
                                                                    .data![
                                                                        index]
                                                                    .voto
                                                                    .toString() +
                                                                ((snapshot
                                                                            .data![
                                                                                index]
                                                                            .lode ??
                                                                        false)
                                                                    ? 'L'
                                                                    : ''),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                trailing: IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () => Navigator
                                                                  .of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              EditEsame(
                                                                                nome: snapshot.data![index].nome,
                                                                                esame: snapshot.data![index],
                                                                                esami: snapshot.data!,
                                                                              )))
                                                              .then((_) =>
                                                                  setState(
                                                                    () {},
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
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Elimina esame'),
                                                                      content: Text(
                                                                          'Sei sicuro di voler eliminare l\'esame "${snapshot.data![index].nome}"'),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Sì'),
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.of(context).pop();
                                                                            await database.delete('esame',
                                                                                where: "nome = '${snapshot.data![index].nome}'");
                                                                            await database.delete('appartenenza',
                                                                                where: "esame = '${snapshot.data![index].nome}'");
                                                                            await database.rawDelete("DELETE FROM categoria AS C "
                                                                                "WHERE NOT EXISTS ("
                                                                                "SELECT * FROM appartenenza AS A "
                                                                                "WHERE A.categoria = C.nome)");
                                                                            setState(() {});
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('No'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
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
                                );
                        }
                      }),
                ),
                const SizedBox(
                  height: 80.0,
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) => FutureBuilder(
                      future: Esame.getEsami(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return AddEsame(esami: snapshot.data!);
                        }
                      }),
                ))
                .then((_) => setState(() {})),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}
