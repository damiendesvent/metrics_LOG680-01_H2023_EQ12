import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullOpenClose extends StatefulWidget {
  const PullOpenClose({super.key});

  @override
  State<PullOpenClose> createState() => _PullOpenCloseState();
}

class _PullOpenCloseState extends State<PullOpenClose> {
  int nbPullRequestWaiting = 5;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: const EdgeInsets.all(15.0),
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Icon(Icons.pie_chart_outline_rounded),
                  Text(
                      "Rapport entre le nombre de pull-request ouverte et fermé")
                ])));
  }
}
