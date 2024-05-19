import 'package:flutter/material.dart';

class Statistiche extends StatefulWidget {
  const Statistiche({super.key});

  @override
  State<Statistiche> createState() => _StatisticheState();
}

class _StatisticheState extends State<Statistiche> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[],
        ),
      ),
    );
  }
}
