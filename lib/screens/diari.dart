import 'package:flutter/material.dart';
import 'package:path2degree/screens/add_diario.dart';

class Diari extends StatefulWidget {
  const Diari({super.key});

  @override
  State<Diari> createState() => _DiariState();
}

class _DiariState extends State<Diari> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
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
                        leading: const Icon(Icons.book, color: Colors.white),
                        title: Text('Diario ${index + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                        subtitle: Opacity(
                          opacity: .5,
                          child: Text('Esame ${index + 2}',
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddDiario())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
