import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/categoria.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/model/tipologia.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class AddEsame extends StatefulWidget {
  const AddEsame({super.key, required this.esami});

  final List<Esame> esami;

  @override
  State<AddEsame> createState() => _AddEsameState();
}

class _AddEsameState extends State<AddEsame> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final List<String> _categorie = [];
  String? _voto;
  Tipologia _tipologia = Tipologia.scrittoOrale;
  String? _diario;
  List<Map<String, Object?>> _diari = [];
  final Map<Tipologia, String> _tipologie = {
    Tipologia.orale: 'Orale',
    Tipologia.scritto: 'Scritto',
    Tipologia.scrittoOrale: 'Scritto + Orale'
  };
  String? _nuovoDiario;

  String? nome;
  String? corsoDiStudi;
  int? cfu;
  DateTime? data;
  DateTime? ora;
  String? luogo;
  Tipologia? tipologia;
  String? docente;
  int? voto;
  bool? lode;
  List<Categoria> categorie = [];
  Diario? diario;

  Future<List<Map<String, Object?>>> _getDiari(databaseProvider) async {
    Database database = await databaseProvider.database;
    return database.rawQuery(
        'SELECT * FROM diario AS D WHERE NOT EXISTS (SELECT * FROM esame AS E WHERE E.diario = D.nome)');
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Aggiungi Esame',
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
                      child: Text('Solo l\'essenziale',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Specificare un nome valido.';
                                } else if (widget.esami
                                    .map((esame) => esame.nome)
                                    .where((nomeEsame) => nomeEsame != nome)
                                    .contains(value.trim())) {
                                  return 'Esiste già un esame con questo nome.';
                                }
                                return null;
                              },
                              onSaved: (newValue) => nome = newValue,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nome'),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 618,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare il corso di studi.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => corsoDiStudi = newValue,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Corso di Studi'),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 382,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare i CFU.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    cfu = int.parse(newValue!),
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'CFU'),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 382,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare la data.';
                                  }
                                  return null;
                                },
                                controller: _dateController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Data'),
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(picked);
                                      data = picked;
                                    });
                                  }
                                },
                                readOnly: true,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 236,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare l\'ora.';
                                  }
                                  return null;
                                },
                                controller: _timeController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Ora'),
                                onTap: () async {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      DateTime now = DateTime.now();
                                      DateTime today = DateTime(
                                          now.year, now.month, now.day);
                                      _timeController.text = DateFormat('HH:mm')
                                          .format(today.add(Duration(
                                              hours: pickedTime.hour,
                                              minutes: pickedTime.minute)));
                                      ora = today.add(Duration(
                                          hours: pickedTime.hour,
                                          minutes: pickedTime.minute));
                                    });
                                  }
                                },
                                readOnly: true,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 382,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare il luogo.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => luogo = newValue,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Luogo'),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dettagli sull\'esame',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Opacity(
                      opacity: .5,
                      child: Text('Dicci qualcosa in più :)',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: DropdownButtonFormField<Tipologia>(
                              onSaved: (newValue) => tipologia = newValue,
                              value: _tipologia,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Tipologia',
                              ),
                              onChanged: (Tipologia? newValue) {
                                setState(() {
                                  _tipologia = newValue!;
                                });
                              },
                              items: Tipologia.values
                                  .map<DropdownMenuItem<Tipologia>>(
                                      (Tipologia value) {
                                return DropdownMenuItem<Tipologia>(
                                  value: value,
                                  child: Text(_tipologie[value]!),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 618,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare il docente.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => docente = newValue,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Docente'),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 382,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: DropdownButtonFormField<String>(
                                onSaved: (newValue) {
                                  if (newValue == null) return;
                                  voto = newValue == '30L'
                                      ? 30
                                      : int.parse(newValue);
                                  lode = newValue == '30L';
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Voto',
                                ),
                                items: [
                                  ...List.generate(
                                      13,
                                      (index) => DropdownMenuItem<String>(
                                          value: (18 + index).toString(),
                                          child:
                                              Text((18 + index).toString()))),
                                  const DropdownMenuItem<String>(
                                      value: '30L', child: Text('30L'))
                                ].reversed.toList(),
                                value: _voto,
                                onChanged: (value) => _voto = value,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categorie dell\'esame',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Opacity(
                      opacity: .5,
                      child: Text('Classifichiamo quest\'esame',
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
                          validator: (value) {
                            if (_categorie.isEmpty) {
                              return 'Specificare almeno una categoria.';
                            }
                            return null;
                          },
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Categoria'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              String nomeCategoria = _categoriaController.text;
                              nomeCategoria =
                                  nomeCategoria.trim().toLowerCase();
                              if (nomeCategoria.isEmpty) {
                                return;
                              }
                              if (!_categorie.contains(nomeCategoria)) {
                                _categorie.add(nomeCategoria);
                                categorie.add(Categoria(nome: nomeCategoria));
                              }
                              _categoriaController.clear();
                            });
                          },
                          icon: const Icon(Icons.add_rounded)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categorie.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.3),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: ListTile(
                              title: Text(_categorie[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Diario dell\'esame',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Opacity(
                      opacity: .5,
                      child: Text('Scegliamo un diario per l\'esame',
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
                        child: FutureBuilder(
                            future: _getDiari(databaseProvider),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Errore'),
                                      content: Text(snapshot.error.toString()),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return Container();
                              } else {
                                _diari = snapshot.data!;
                                return DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Specificare il diario.';
                                    }
                                    return null;
                                  },
                                  value: _diario,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Diario',
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _diario = newValue!;
                                      diario = Diario(nome: _diario!);
                                    });
                                  },
                                  items: _diari.map<DropdownMenuItem<String>>(
                                      (Map<String, Object?> value) {
                                    return DropdownMenuItem<String>(
                                      value: value['nome'] as String,
                                      child: Text(value['nome'] as String),
                                    );
                                  }).toList(),
                                );
                              }
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Nuovo diario'),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Nome del diario'),
                                    onChanged: (value) {
                                      _nuovoDiario = value;
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Annulla'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Aggiungi'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        final newDiario =
                                            Diario(nome: _nuovoDiario!);
                                        Database db =
                                            await databaseProvider.database;
                                        await db.insert(
                                          'diario',
                                          newDiario.toMap(),
                                          conflictAlgorithm:
                                              ConflictAlgorithm.replace,
                                        );
                                        _diario = _nuovoDiario;
                                        diario = newDiario;
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.add_rounded)),
                    )
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                DateTime now = DateTime.now();
                                DateTime today =
                                    DateTime(now.year, now.month, now.day);
                                databaseProvider.database
                                    .then((database) async {
                                  await database.insert(
                                      'esame',
                                      {
                                        'nome': nome!,
                                        'corsoDiStudi': corsoDiStudi!,
                                        'cfu': cfu!,
                                        'dataOra': data!
                                            .add(ora!.difference(today))
                                            .toIso8601String(),
                                        'luogo': luogo!,
                                        'tipologia': tipologia!.name,
                                        'docente': docente!,
                                        'voto': voto,
                                        'lode': lode,
                                        'diario': diario!.nome
                                      },
                                      conflictAlgorithm:
                                          ConflictAlgorithm.replace);
                                  for (final categoria in _categorie) {
                                    await database.insert(
                                        'categoria',
                                        {
                                          'nome': categoria,
                                        },
                                        conflictAlgorithm:
                                            ConflictAlgorithm.replace);
                                    await database.insert(
                                      'appartenenza',
                                      {
                                        'esame': nome!,
                                        'categoria': categoria,
                                      },
                                      conflictAlgorithm:
                                          ConflictAlgorithm.replace,
                                    );
                                  }
                                }).then((_) => Navigator.of(context).pop());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            child: const Text('Aggiungi esame')),
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
}
