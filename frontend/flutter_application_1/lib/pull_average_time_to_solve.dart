import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullAverageTimeToSolve extends StatefulWidget {
  const PullAverageTimeToSolve({super.key});

  @override
  State<PullAverageTimeToSolve> createState() => _PullAverageTimeToSolveState();
}

class _PullAverageTimeToSolveState extends State<PullAverageTimeToSolve> {
  String averageTime = "5h50";

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.av_timer_rounded, size: 25),
                  Text("Temps moyen de résolution d'une pull-request")
                ]),
            Chip(
                avatar: const Icon(Icons.access_time_rounded),
                backgroundColor: Colors.blue.shade100,
                label: Text(
                  "$averageTime", //"5d:5h",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ))
          ]),
    ));
  }
}
