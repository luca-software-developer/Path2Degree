import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/categoria.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/model/tipologia.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/utils/local_notification_service.dart';
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

  // Controller per l'inserimento di data, ora e categoria.
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _categoriaController = TextEditingController();

  // Valori selezionati dall'utente.
  final List<String> _selectedCategorie = [];
  String? _selectedVoto;
  Tipologia _selectedTipologia = Tipologia.scrittoOrale;
  String? _selectedDiario;
  List<Map<String, Object?>> _diari = [];

  //  Tipologie di esame rappresentate come stringhe.
  final Map<Tipologia, String> _tipologie = {
    Tipologia.orale: 'Orale',
    Tipologia.scritto: 'Scritto',
    Tipologia.scrittoOrale: 'Scritto + Orale'
  };
  String? _nuovoDiario;

  //  Dati dell'esame.
  String? _nome;
  String? _corsoDiStudi;
  int? _cfu;
  DateTime? _data;
  DateTime? _ora;
  String? _luogo;
  Tipologia? _tipologia;
  String? _docente;
  int? _voto;
  bool? _lode;
  final List<Categoria> _categorie = [];
  Diario? _diario;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _categoriaController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Specificare un nome valido.';
                                  } else if (widget.esami
                                      .map((esame) => esame.nome)
                                      .where((nomeEsame) => nomeEsame != _nome)
                                      .contains(value.trim())) {
                                    return 'Esiste già un esame con questo nome.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => _nome = newValue!.trim(),
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
                                  onSaved: (newValue) =>
                                      _corsoDiStudi = newValue!.trim(),
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
                                      _cfu = int.parse(newValue!),
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
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      locale: const Locale('it', 'IT'),
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _dateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(picked);
                                        _data = picked;
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
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: Localizations.override(
                                            context: context,
                                            locale: const Locale('it', 'IT'),
                                            child: child,
                                          ),
                                        );
                                      },
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        DateTime now = DateTime.now();
                                        DateTime today = DateTime(
                                            now.year, now.month, now.day);
                                        _timeController.text =
                                            DateFormat('HH:mm').format(
                                                today.add(Duration(
                                                    hours: pickedTime.hour,
                                                    minutes:
                                                        pickedTime.minute)));
                                        _ora = today.add(Duration(
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
                                  onSaved: (newValue) =>
                                      _luogo = newValue!.trim(),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0.0),
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: DropdownButtonFormField<Tipologia>(
                                onSaved: (newValue) => _tipologia = newValue,
                                value: _selectedTipologia,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  labelText: 'Tipologia',
                                ),
                                onChanged: (Tipologia? newValue) {
                                  setState(() {
                                    _selectedTipologia = newValue!;
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
                                  onSaved: (newValue) =>
                                      _docente = newValue!.trim(),
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
                                    if (newValue == null || newValue.isEmpty) {
                                      return;
                                    }
                                    _voto = newValue == '30L'
                                        ? 30
                                        : int.parse(newValue);
                                    _lode = newValue == '30L';
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    labelText: 'Voto',
                                  ),
                                  items: _data?.isAfter(DateTime.now()) ?? false
                                      ? []
                                      : [
                                          const DropdownMenuItem<String>(
                                              value: '', child: Text('N/A')),
                                          ...List.generate(
                                              13,
                                              (index) =>
                                                  DropdownMenuItem<String>(
                                                      value: (18 + index)
                                                          .toString(),
                                                      child: Text((18 + index)
                                                          .toString()))),
                                          const DropdownMenuItem<String>(
                                              value: '30L', child: Text('30L'))
                                        ].reversed.toList(),
                                  value: _selectedVoto,
                                  onChanged: (value) => _selectedVoto = value,
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
                        child: FutureBuilder(
                            future: Categoria.getCategorie(context),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              } else {
                                return Autocomplete<String>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return snapshot.data!
                                        .map((categoria) => categoria.nome)
                                        .where((String option) {
                                      return !_selectedCategorie
                                              .contains(option) &&
                                          option.contains(textEditingValue.text
                                              .trim()
                                              .toLowerCase());
                                    });
                                  },
                                  onSelected: (String selection) {
                                    _categoriaController.text = selection;
                                  },
                                  fieldViewBuilder: (context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted) {
                                    return TextFormField(
                                      validator: (value) {
                                        if (_selectedCategorie.isEmpty) {
                                          return 'Specificare almeno una categoria.';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) => _categoriaController
                                          .text = textEditingController.text,
                                      focusNode: focusNode,
                                      controller: textEditingController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Categoria',
                                      ),
                                    );
                                  },
                                );
                              }
                            }),
                      )),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                String nomeCategoria =
                                    _categoriaController.text;
                                nomeCategoria =
                                    nomeCategoria.trim().toLowerCase();
                                if (nomeCategoria.isEmpty) {
                                  return;
                                }
                                if (!_selectedCategorie
                                    .contains(nomeCategoria)) {
                                  _selectedCategorie.add(nomeCategoria);
                                  _categorie
                                      .add(Categoria(nome: nomeCategoria));
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
                        itemCount: _selectedCategorie.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: ListTile(
                                title: Text(_selectedCategorie[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setState(
                                      () => _selectedCategorie.removeAt(index)),
                                ),
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
                              future: Diario.getDiariAssegnabili(context),
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
                                        content:
                                            Text(snapshot.error.toString()),
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
                                    value: _selectedDiario,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      labelText: 'Diario',
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedDiario = newValue!;
                                        _diario =
                                            Diario(nome: _selectedDiario!);
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
                                        _nuovoDiario = value.trim();
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
                                          if (_nuovoDiario == null ||
                                              _nuovoDiario!.trim().isEmpty) {
                                            return;
                                          }
                                          final newDiario =
                                              Diario(nome: _nuovoDiario!);
                                          Database db =
                                              await databaseProvider.database;
                                          await db.insert(
                                            'diario',
                                            newDiario.toMap(),
                                            conflictAlgorithm:
                                                ConflictAlgorithm.ignore,
                                          );
                                          _selectedDiario = _nuovoDiario;
                                          _diario = newDiario;
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
                                DateTime now = DateTime.now();
                                DateTime today =
                                    DateTime(now.year, now.month, now.day);
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  databaseProvider.database
                                      .then((database) async {
                                    await database.insert(
                                        'esame',
                                        {
                                          'nome': _nome!,
                                          'corsoDiStudi': _corsoDiStudi!,
                                          'cfu': _cfu!,
                                          'dataOra': _data!
                                              .add(_ora!.difference(today))
                                              .toIso8601String(),
                                          'luogo': _luogo!,
                                          'tipologia': _tipologia!.name,
                                          'docente': _docente!,
                                          'voto': _voto,
                                          'lode': _lode,
                                          'diario': _diario!.nome
                                        },
                                        conflictAlgorithm:
                                            ConflictAlgorithm.replace);
                                    for (final categoria
                                        in _selectedCategorie) {
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
                                          'esame': _nome!,
                                          'categoria': categoria,
                                        },
                                        conflictAlgorithm:
                                            ConflictAlgorithm.replace,
                                      );
                                    }
                                  }).then((_) async {
                                    EsameNotificationService service =
                                        EsameNotificationService();
                                    await service.initialize();
                                    await service.scheduleExamNotification(
                                        _nome!,
                                        _data!.add(_ora!.difference(today)),
                                        _luogo!);
                                  }).then((_) => Navigator.of(context).pop());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
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
    );
  }
}
