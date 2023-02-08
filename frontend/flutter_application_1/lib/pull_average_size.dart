import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullAverageSize extends StatefulWidget {
  const PullAverageSize({super.key});

  @override
  State<PullAverageSize> createState() => _PullAverageSizeState();
}

class _PullAverageSizeState extends State<PullAverageSize> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            child: Wrap(children: [
      Icon(Icons.format_line_spacing_rounded),
      Text("Taille moyenne d'un pull request")
    ])));
  }
}
