import 'package:flutter/material.dart';
import 'package:path2degree/model/risorsa.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class AddRisorsa extends StatefulWidget {
  const AddRisorsa({super.key, required this.diario, required this.risorse});

  final String diario;
  final List<Risorsa> risorse;

  @override
  State<AddRisorsa> createState() => _AddRisorsaState();
}

class _AddRisorsaState extends State<AddRisorsa> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _nome;
  String? _path;

  @override
  Widget build(BuildContext context) {
    _controller.text =
        _path != null ? path.basename(_path!) : 'Nessun file selezionato';
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Aggiungi Risorsa',
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
                              style: Theme.of(context).textTheme.bodyMedium),
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
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Specificare un nome valido.';
                                    } else if (widget.risorse
                                        .map((risorsa) => risorsa.nome)
                                        .where((nomeRisorsa) =>
                                            nomeRisorsa != _nome)
                                        .contains(value.trim())) {
                                      return 'Esiste già una risorsa con questo nome.';
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
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              controller: _controller,
                              readOnly: true,
                              validator: (value) {
                                if (_path == null) {
                                  return 'Scegliere un file.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                  child: const Text('Scegli'),
                                  onPressed: () async {
                                    _path = await Risorsa.showFilePicker();
                                    if (_path == null) return;
                                    setState(() => _controller.text =
                                        path.basename(_path!));
                                  },
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
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
                                          .insert(
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
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary),
                                child: const Text('Salva')),
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
        ),
      ),
    );
  }
}
