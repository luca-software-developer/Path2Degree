import 'package:flutter/material.dart';
import 'package:path2degree/main.dart';

class Informazioni extends StatefulWidget {
  const Informazioni({super.key});

  @override
  State<Informazioni> createState() => _InformazioniState();
}

class _InformazioniState extends State<Informazioni> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Informazioni',
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 256,
                        child: Image.asset(
                          'assets/icons/icon.png',
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Text(
              Path2Degree.title,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Path2Degree è un’applicazione mobile multipiattaforma per la gestione degli esami universitari. L’app consente di elencare gli esami universitari nella propria carriera, categorizzarli, inserire note, promemoria e monitorare i progressi.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
