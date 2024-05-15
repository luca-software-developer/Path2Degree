import 'package:flutter/material.dart';

class AddEsame extends StatefulWidget {
  const AddEsame({super.key});

  @override
  State<AddEsame> createState() => _AddEsameState();
}

class _AddEsameState extends State<AddEsame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Aggiungi Esame',
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
