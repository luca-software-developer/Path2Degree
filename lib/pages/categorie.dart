import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:path2degree/model/categoria.dart';

class Categorie extends StatefulWidget {
  const Categorie({super.key});

  @override
  State<Categorie> createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, mode, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'Cerca categorie...',
                        prefixIcon: Icon(Icons.search_rounded)),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                FutureBuilder(
                    future: Categoria.getCategorie(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: snapshot.data!.isEmpty
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text('Nessun elemento'),
                                ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return _controller.text.trim().isNotEmpty &&
                                            !snapshot.data![index].nome
                                                .trim()
                                                .toLowerCase()
                                                .contains(_controller.text
                                                    .trim()
                                                    .toLowerCase())
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 16, 16, 0),
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
                                                  leading: const Icon(
                                                      Icons.category_rounded),
                                                  title: Text(
                                                      snapshot
                                                          .data![index].nome,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AdaptiveTheme.of(
                                                                              context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black))),
                                            ),
                                          );
                                  },
                                ),
                        );
                      }
                    }),
                const SizedBox(
                  height: 8.0,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
