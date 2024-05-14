import 'package:flutter/material.dart';
import 'package:path2degree/main.dart';
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(Path2Degree.title,
            style: Theme.of(context).textTheme.displaySmall),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {},
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                Path2Degree.title,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
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
            ListView.builder(
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
            )
          ],
        ),
      ),
    );
  }
}
