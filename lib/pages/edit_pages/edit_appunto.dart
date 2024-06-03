import 'package:flutter/material.dart';
import 'package:path2degree/model/appunto.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';

class EditAppunto extends StatefulWidget {
  const EditAppunto({super.key, required this.nome, required this.appunti});

  final String nome;
  final List<Appunto> appunti;

  @override
  State<EditAppunto> createState() => _EditAppuntoState();
}

class _EditAppuntoState extends State<EditAppunto> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _nome;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Appunto.getTesto(context, widget.nome),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            _controller.text = snapshot.data!;
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text('Modifica "${widget.nome}"',
                        style: Theme.of(context).textTheme.displaySmall),
                  ),
                  body: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Nome dell\'appunto'),
                                        initialValue: widget.nome,
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
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _controller,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Inizia a scrivere qui...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
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
                                                    'appunto',
                                                    {
                                                      'nome': _nome,
                                                      'testo': _controller.text
                                                    },
                                                    where:
                                                        "nome = '${widget.nome}'")
                                                .then((_) =>
                                                    Navigator.of(context)
                                                        .pop());
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
                                      child: const Text('Salva')),
                                ),
                              )
                            ],
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
        });
  }
}
