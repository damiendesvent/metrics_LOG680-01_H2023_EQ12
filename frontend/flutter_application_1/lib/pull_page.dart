import 'main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pull_nb_en_attente.dart';

class PullPageLayout extends StatefulWidget {
  const PullPageLayout({super.key});

  @override
  State<PullPageLayout> createState() => _PullPageLayout();
}

class _PullPageLayout extends State<PullPageLayout> {
  @override
  Widget build(BuildContext context) {
    return PullNbEnAttente();
  }
}
