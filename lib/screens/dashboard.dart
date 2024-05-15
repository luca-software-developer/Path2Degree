import 'package:flutter/material.dart';
import 'package:path2degree/screens/add_diario.dart';
import 'package:path2degree/screens/add_esame.dart';
import 'package:path2degree/widgets/action_button.dart';
import 'package:path2degree/widgets/expandable_fab.dart';
import 'package:table_calendar/table_calendar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              locale: 'it_IT',
              firstDay: DateTime.utc(1970, 01, 01),
              lastDay: DateTime.utc(2038, 31, 12),
              focusedDay: DateTime.now(),
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Questo mese',
                CalendarFormat.week: 'Questa settimana'
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text('Promemoria automatici',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Opacity(
                      opacity: .5,
                      child: Text('Esami entro il 30 maggio 2024',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.alarm, color: Colors.white),
                        title: Text('Esame ${index + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                        subtitle: Opacity(
                          opacity: .5,
                          child: Text('12 maggio 2024 — 12:00',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddDiario())),
            icon: const Icon(Icons.book),
          ),
          ActionButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddEsame())),
            icon: const Icon(Icons.school),
          ),
        ],
      ),
    );
  }
}
