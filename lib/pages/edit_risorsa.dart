import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:path2degree/model/risorsa.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class EditRisorsa extends StatefulWidget {
  const EditRisorsa({super.key, required this.nome, required this.diario});

  final String nome;
  final String diario;

  @override
  State<EditRisorsa> createState() => _EditRisorsaState();
}

class _EditRisorsaState extends State<EditRisorsa> {
  final _formKey = GlobalKey<FormState>();
  String? _nome;
  String? _path;

  Future<String> _getPath() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows =
        await database.query('risorsa', where: "nome = '${widget.nome}'");
    return rows[0]['path'] as String;
  }

  Future<String?> _getPathRisorsa() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPath(),
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
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Modifica "${widget.nome}"',
                    style: Theme.of(context).textTheme.displaySmall),
              ),
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informazioni di base',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Opacity(
                              opacity: .5,
                              child: Text(
                                  'Che nome vogliamo dare a questa risorsa?',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0.0),
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Nome della risorsa'),
                                      initialValue: widget.nome,
                                      validator: (value) {
                                        if (value!.trim().isEmpty) {
                                          return 'Specificare un nome valido.';
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) =>
                                          _nome = newValue!.trim(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scegli un file',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Opacity(
                              opacity: .5,
                              child: Text('Seleziona il file della risorsa.',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(_path != null
                                        ? path.basename(_path!)
                                        : path.basename(snapshot.data!)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0.0),
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: ElevatedButton(
                                        child: const Text('Scegli risorsa'),
                                        onPressed: () async {
                                          _path = await _getPathRisorsa();
                                          setState(() {});
                                        },
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        Provider.of<DatabaseProvider>(context,
                                                listen: false)
                                            .database
                                            .then((database) {
                                          database
                                              .update(
                                                'risorsa',
                                                Risorsa(
                                                        nome: _nome!,
                                                        path: _path!,
                                                        diario: widget.diario)
                                                    .toMap(),
                                                conflictAlgorithm:
                                                    ConflictAlgorithm.replace,
                                              )
                                              .then((_) =>
                                                  Navigator.of(context).pop());
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: const Text('Modifica risorsa')),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
