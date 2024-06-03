import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path2degree/providers/shared_preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Icone relative ai temi dell'app: chiaro (sunny), scuro (brightness_2)
/// e di sistema (auto_fix_high),
const List<Widget> modeIcons = <Widget>[
  Icon(Icons.sunny),
  Icon(Icons.brightness_2),
  Icon(Icons.auto_fix_high),
];

class Impostazioni extends StatefulWidget {
  const Impostazioni({super.key});

  @override
  State<Impostazioni> createState() => _ImpostazioniState();
}

class _ImpostazioniState extends State<Impostazioni> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  DateTime? data;

  @override
  Widget build(BuildContext context) {
    final List<bool> selectedMode = <bool>[
      AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
      AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark,
      AdaptiveTheme.of(context).mode == AdaptiveThemeMode.system,
    ];
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Impostazioni',
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
                        Text('Promemoria automatici',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Opacity(
                          opacity: .5,
                          child: Text(
                              'Gli esami imminenti sono gli esami entro la data...',
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
                                padding: const EdgeInsets.only(right: 4.0),
                                child: FutureBuilder(
                                    future: SharedPreferences.getInstance(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return TextFormField(
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Scegli una data'),
                                          readOnly: true,
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        final prefs = snapshot.data!;
                                        if (data == null &&
                                            prefs.containsKey(
                                                'dataPromemoria')) {
                                          data = DateTime.parse(prefs
                                              .getString('dataPromemoria')!);
                                          _dateController.text =
                                              DateFormat('dd/MM/yyyy')
                                                  .format(data!);
                                        }
                                        return TextFormField(
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Specificare una data valida.';
                                            } else if (data!
                                                .isBefore(DateTime.now())) {
                                              return 'La data deve essere successiva alla data odierna.';
                                            }
                                            return null;
                                          },
                                          controller: _dateController,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Scegli una data'),
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              locale: const Locale('it', 'IT'),
                                              initialDate: data,
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
                                        );
                                      }
                                    }),
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
                                    Provider.of<SharedPreferencesProvider>(
                                            context,
                                            listen: false)
                                        .setDataPromemoria(
                                            data!.toIso8601String());
                                    Navigator.of(context).pop();
                                  }
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tema dell\'app',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Opacity(
                          opacity: .5,
                          child: Text('Scegli il tema che preferisci!',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < selectedMode.length; i++) {
                            selectedMode[i] = i == index;
                          }
                          if (selectedMode[0]) {
                            AdaptiveTheme.of(context).setLight();
                          } else if (selectedMode[1]) {
                            AdaptiveTheme.of(context).setDark();
                          } else {
                            AdaptiveTheme.of(context).setSystem();
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      isSelected: selectedMode,
                      children: modeIcons,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
