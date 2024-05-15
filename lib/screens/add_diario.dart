import 'package:flutter/material.dart';

class AddDiario extends StatefulWidget {
  const AddDiario({super.key});

  @override
  State<AddDiario> createState() => _AddDiarioState();
}

class _AddDiarioState extends State<AddDiario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Aggiungi Diario',
            style: Theme.of(context).textTheme.displaySmall),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[],
        ),
      ),
    );
  }
}
