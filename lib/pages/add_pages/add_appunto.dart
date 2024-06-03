import 'package:flutter/material.dart';
import 'package:path2degree/model/appunto.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddAppunto extends StatefulWidget {
  const AddAppunto({super.key, required this.diario, required this.appunti});

  final String diario;
  final List<Appunto> appunti;

  @override
  State<AddAppunto> createState() => _AddAppuntoState();
}

class _AddAppuntoState extends State<AddAppunto> {
  final _formKey = GlobalKey<FormState>();
  String? _nome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Aggiungi Appunto',
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
                              'Che nome vogliamo dare a questo appunto?',
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
                                      labelText: 'Nome dell\'appunto'),
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Specificare un nome valido.';
                                    } else if (widget.appunti
                                        .map((appunto) => appunto.nome)
                                        .where((nomeAppunto) =>
                                            nomeAppunto != _nome)
                                        .contains(value.trim())) {
                                      return 'Esiste già un appunto con questo nome.';
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
                                          .insert(
                                            'appunto',
                                            Appunto(
                                                    nome: _nome!,
                                                    testo: '',
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
                                child: const Text('Aggiungi appunto')),
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
