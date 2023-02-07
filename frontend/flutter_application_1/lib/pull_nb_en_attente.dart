import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullNbEnAttente extends StatefulWidget {
  const PullNbEnAttente({super.key});

  @override
  State<PullNbEnAttente> createState() => _PullNbEnAttenteState();
}

class _PullNbEnAttenteState extends State<PullNbEnAttente> {
  int nbPullRequestWaiting = 5;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.spaceBetween,
          spacing: 15,
          children: [
            Icon(Icons.warning_amber_rounded, size: 25),
            Text("Nombre de pull request en attente"),
            Text("$nbPullRequestWaiting")
          ]),
    ));
  }
}
