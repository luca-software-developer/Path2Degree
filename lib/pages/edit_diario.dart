import 'package:flutter/material.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';

class EditDiario extends StatefulWidget {
  const EditDiario({super.key, required this.nome});

  final String nome;

  @override
  State<EditDiario> createState() => _EditDiarioState();
}

class _EditDiarioState extends State<EditDiario> {
  final _controller = TextEditingController();

  Future<String> _getTesto() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows =
        await database.query('diario', where: "nome = '${widget.nome}'");
    return rows[0]['testo'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTesto(),
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
            _controller.text = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Modifica "${widget.nome}"',
                    style: Theme.of(context).textTheme.displaySmall),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
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
                                  Provider.of<DatabaseProvider>(context,
                                          listen: false)
                                      .database
                                      .then((database) {
                                    database
                                        .update('diario',
                                            {'testo': _controller.text},
                                            where: "nome = '${widget.nome}'")
                                        .then(
                                            (_) => Navigator.of(context).pop());
                                  });
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
                    const SizedBox(
                      height: 8.0,
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
