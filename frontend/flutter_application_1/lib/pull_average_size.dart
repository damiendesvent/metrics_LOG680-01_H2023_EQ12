import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double averageSize = 2;

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
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.format_line_spacing_rounded),
                      Text("Taille moyenne d'une pull request "),
                    ],
                  ),
                  Tooltip(
                      message: "Nombre de commits",
                      child: Chip(
                          backgroundColor: Colors.blue.shade100,
                          avatar: const Icon(Icons.format_line_spacing_rounded),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          label: Text(
                            '$averageSize commits',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )))
                ])));
  }
}
