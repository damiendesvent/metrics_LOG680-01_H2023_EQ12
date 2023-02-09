import 'main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pull_nb_en_attente.dart';
import 'package:flutter_application_1/pull_average_time_to_solve.dart';
import 'package:flutter_application_1/pull_rq_closed_open.dart';
import 'package:flutter_application_1/pull_nb_average_comments.dart';

class PullPageLayout extends StatefulWidget {
  const PullPageLayout({super.key});

  @override
  State<PullPageLayout> createState() => _PullPageLayout();
}

class _PullPageLayout extends State<PullPageLayout> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: PullNbEnAttente()),
        Expanded(child: PullAverageTimeToSolve()),
      ]),
      PullOpenClose(),
      PullAverageComments()
    ]);
  }
}
