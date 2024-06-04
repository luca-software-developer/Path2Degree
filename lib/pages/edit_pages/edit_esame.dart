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

class EditEsame extends StatefulWidget {
  const EditEsame(
      {super.key,
      required this.nome,
      required this.esame,
      required this.esami});

  final String nome;
  final Esame esame;
  final List<Esame> esami;

  @override
  State<EditEsame> createState() => _EditEsameState();
}

class _EditEsameState extends State<EditEsame> {
  final _formKey = GlobalKey<FormState>();

  // Controller per l'inserimento di data, ora e categoria.
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _categoriaController = TextEditingController();

  // Valori selezionati dall'utente.
  List<String> _selectedCategorie = [];
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
  TimeOfDay? _ora;
  String? _luogo;
  Tipologia? _tipologia;
  String? _docente;
  int? _voto;
  bool? _lode;
  List<Categoria> _categorie = [];
  String? _diario;

  late Esame _esame;

  final _scrollController = ScrollController();

  ///  Restituisce la rappresentazione HH:mm di un oggetto TimeOfDay.
  String getFormattedTime(TimeOfDay time) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return DateFormat('HH:mm')
        .format(today.add(Duration(hours: time.hour, minutes: time.minute)));
  }

  @override
  void initState() {
    super.initState();
    _esame = widget.esame;
    _nome = _esame.nome;
    _corsoDiStudi = _esame.corsoDiStudi;
    _cfu = _esame.cfu;
    _data =
        DateTime(_esame.dataOra.year, _esame.dataOra.month, _esame.dataOra.day);
    _ora = TimeOfDay.fromDateTime(_esame.dataOra);
    _luogo = _esame.luogo;
    _tipologia = _esame.tipologia;
    _docente = _esame.docente;
    _voto = _esame.voto;
    _lode = _esame.lode;
    _selectedVoto = _esame.voto == null
        ? ''
        : (_esame.voto.toString() + ((_lode ?? false) ? 'L' : ''));
    _diario = _esame.diario;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_data!);
    _timeController.text = getFormattedTime(_ora!);
    _selectedTipologia = _esame.tipologia;
    _selectedDiario = _esame.diario;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _categoriaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Modifica "${widget.nome}"',
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                                onSaved: (newValue) => _nome = newValue,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nome'),
                                initialValue: _esame.nome,
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
                                      _corsoDiStudi = newValue,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Corso di Studi'),
                                  initialValue: _esame.corsoDiStudi,
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
                                  initialValue: _esame.cfu.toString(),
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
                                      initialDate: _data,
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
                                      initialTime: _ora!,
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
                                        _ora = pickedTime;
                                        _timeController.text =
                                            getFormattedTime(_ora!);
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
                                    onSaved: (newValue) => _luogo = newValue,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Luogo'),
                                    initialValue: _esame.luogo),
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
                                  onSaved: (newValue) => _docente = newValue,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Docente'),
                                  initialValue: _esame.docente,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 382,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: DropdownButtonFormField<String?>(
                                  onSaved: (newValue) {
                                    if (newValue == null || newValue.isEmpty) {
                                      _voto = null;
                                      _lode = null;
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
                FutureBuilder(
                    future: Esame.getCategorieEsame(context, widget.nome),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        _selectedCategorie = snapshot.data!;
                        _categorie = snapshot.data!
                            .map((nomeCategoria) =>
                                Categoria(nome: nomeCategoria))
                            .toList();
                        return Column(children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                                            return Text(
                                                snapshot.error.toString());
                                          } else {
                                            return Autocomplete<String>(
                                              optionsBuilder: (TextEditingValue
                                                  textEditingValue) {
                                                if (textEditingValue
                                                    .text.isEmpty) {
                                                  return const Iterable<
                                                      String>.empty();
                                                }
                                                return snapshot.data!
                                                    .map((categoria) =>
                                                        categoria.nome)
                                                    .where((String option) {
                                                  return !_selectedCategorie
                                                          .contains(option) &&
                                                      option.contains(
                                                          textEditingValue.text
                                                              .trim()
                                                              .toLowerCase());
                                                });
                                              },
                                              onSelected: (String selection) {
                                                _categoriaController.text =
                                                    selection;
                                              },
                                              fieldViewBuilder: (context,
                                                  textEditingController,
                                                  focusNode,
                                                  onFieldSubmitted) {
                                                return TextFormField(
                                                  validator: (value) {
                                                    if (_selectedCategorie
                                                        .isEmpty) {
                                                      return 'Specificare almeno una categoria.';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) =>
                                                      _categoriaController
                                                              .text =
                                                          textEditingController
                                                              .text,
                                                  focusNode: focusNode,
                                                  controller:
                                                      textEditingController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Categoria',
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        }),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: IconButton(
                                      onPressed: () async {
                                        final scrollPosition =
                                            _scrollController.offset;
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
                                          _categorie.add(
                                              Categoria(nome: nomeCategoria));
                                        }
                                        _categoriaController.clear();
                                        Database database =
                                            await databaseProvider.database;
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
                                        setState(() {});
                                        _scrollController
                                            .jumpTo(scrollPosition);
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _selectedCategorie.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                          title: Text(_selectedCategorie[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              Database database =
                                                  await databaseProvider
                                                      .database;
                                              await database.delete(
                                                  'appartenenza',
                                                  where:
                                                      "esame = '${widget.nome}' AND categoria = '${_selectedCategorie[index]}'");
                                              await database.rawDelete(
                                                  "DELETE FROM categoria AS C "
                                                  "WHERE NOT EXISTS ("
                                                  "SELECT * FROM appartenenza AS A "
                                                  "WHERE A.categoria = C.nome)");
                                              setState(() {});
                                              _selectedCategorie
                                                  .removeAt(index);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }
                    }),
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
                              future: Diario.getDiariRiassegnabili(
                                  context, _esame.diario),
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
                                          _diario = _selectedDiario;
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
                                  databaseProvider.database
                                      .then((database) async {
                                    await database.update(
                                        'esame',
                                        {
                                          'nome': _nome!,
                                          'corsoDiStudi': _corsoDiStudi!,
                                          'cfu': _cfu!,
                                          'dataOra': _data!
                                              .add(Duration(
                                                  hours: _ora!.hour,
                                                  minutes: _ora!.minute))
                                              .toIso8601String(),
                                          'luogo': _luogo!,
                                          'tipologia': _tipologia!.name,
                                          'docente': _docente!,
                                          'voto':
                                              _data?.isAfter(DateTime.now()) ??
                                                      false
                                                  ? null
                                                  : _voto,
                                          'lode':
                                              _data?.isAfter(DateTime.now()) ??
                                                      false
                                                  ? null
                                                  : (_lode == true ? 1 : 0),
                                          'diario': _diario!
                                        },
                                        where: "nome = '${_esame.nome}'",
                                        conflictAlgorithm:
                                            ConflictAlgorithm.replace);
                                    await database.update(
                                        'appartenenza',
                                        {
                                          'esame': _nome!,
                                        },
                                        where: "esame = '${_esame.nome}'");
                                  }).then((_) async {
                                    EsameNotificationService service =
                                        EsameNotificationService();
                                    await service.initialize();
                                    await service
                                        .cancelExamNotification(_nome!);
                                    await service.scheduleExamNotification(
                                        _nome!,
                                        _data!.add(Duration(
                                            hours: _ora!.hour,
                                            minutes: _ora!.minute)),
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
