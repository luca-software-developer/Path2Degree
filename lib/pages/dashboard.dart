import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/model/diario.dart';
import 'package:path2degree/model/esame.dart';
import 'package:path2degree/pages/add_pages/add_diario.dart';
import 'package:path2degree/pages/add_pages/add_esame.dart';
import 'package:path2degree/providers/database_provider.dart';
import 'package:path2degree/providers/shared_preferences_provider.dart';
import 'package:path2degree/widgets/action_button.dart';
import 'package:path2degree/widgets/expandable_fab.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Esame> esamiPromemoria = [];

  Future<List<Diario>> _getDiari() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('diario');
    return rows.map((row) => Diario(nome: row['nome'] as String)).toList();
  }

  Future<List<Esame>> _getEsami() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  Future<List<Esame>> _getEsamiInCorso() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final database = await provider.database;
    final rows = await database.query('esame', where: 'voto IS NULL');
    return rows.map((row) => Esame.fromMap(row)).toList();
  }

  List<Esame> _getEsamiPrimaDel(List<Esame> esami, DateTime data) {
    List<Esame> promemoria = [];
    for (final esame in esami) {
      if (esame.dataOra.isBefore(data)) {
        promemoria.add(esame);
      }
    }
    return promemoria;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, mode, child) {
          return FutureBuilder(
              future: _getEsamiInCorso(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Scaffold(
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TableCalendar(
                            locale: 'it_IT',
                            firstDay: DateTime.utc(1970, 01, 01),
                            lastDay: DateTime.utc(2038, 31, 12),
                            focusedDay: _focusedDay,
                            eventLoader: (day) {
                              if (snapshot.data == null) return [];
                              List<Esame> esami = snapshot.data!;
                              List<Esame> esamiOggi = [];
                              for (final esame in esami) {
                                if (esame.dataOra.isAfter(day) &&
                                    esame.dataOra.isBefore(
                                        day.add(const Duration(hours: 24)))) {
                                  esamiOggi.add(esame);
                                }
                              }
                              return esamiOggi;
                            },
                            calendarFormat: _calendarFormat,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Questo mese',
                              CalendarFormat.week: 'Questa settimana'
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                  color: mode.isDark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                      : Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(
                                  color: mode.isDark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface
                                      : Colors.black45,
                                  shape: BoxShape.circle),
                              markerDecoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  shape: BoxShape.circle),
                            ),
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              }
                            },
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                          ),
                          Column(
                            children: [
                              Consumer<SharedPreferencesProvider>(
                                  builder: (context, prefs, _) {
                                if (prefs.dataPromemoria == null) {
                                  return Container();
                                }
                                final data =
                                    DateTime.parse(prefs.dataPromemoria!);
                                esamiPromemoria = _getEsamiPrimaDel(
                                    snapshot.data ?? [], data);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text('Promemoria automatici',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Opacity(
                                        opacity: .5,
                                        child: Text(
                                            'Esami entro il ${DateFormat('dd/MM/yyyy').format(DateTime.parse(prefs.dataPromemoria!))}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                    ),
                                    (snapshot.data ?? []).isEmpty
                                        ? const Center(
                                            child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Text('Nessun elemento'),
                                          ))
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: esamiPromemoria.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    border: Border.all(
                                                      width: 1,
                                                      style: BorderStyle.solid,
                                                    ),
                                                  ),
                                                  child: ListTile(
                                                    leading: const Icon(
                                                        Icons.alarm_rounded),
                                                    title: Text(
                                                        esamiPromemoria[index]
                                                            .nome,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                    subtitle: Opacity(
                                                      opacity: .5,
                                                      child: Text(
                                                          '${DateFormat('dd/MM/yyyy').format(esamiPromemoria[index].dataOra)} — ${DateFormat('HH:mm').format(esamiPromemoria[index].dataOra)}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                    const SizedBox(
                                      height: 80.0,
                                    )
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: ExpandableFab(
                      distance: 112,
                      children: [
                        ActionButton(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FutureBuilder(
                                future: _getDiari(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return AddDiario(diari: snapshot.data!);
                                  }
                                }),
                          )),
                          icon: const Icon(Icons.book_rounded),
                        ),
                        ActionButton(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FutureBuilder(
                                future: _getEsami(),
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
                          )),
                          icon: const Icon(Icons.school_rounded),
                        ),
                      ],
                    ),
                  );
                }
              });
        });
  }
}
