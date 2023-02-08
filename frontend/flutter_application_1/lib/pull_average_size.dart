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
            padding: EdgeInsets.all(15.0),
            child:
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Icon(Icons.format_line_spacing_rounded),
              Text("Taille moyenne d'un pull request"),
              Tooltip(
                  message: "Somme de ligne modifié (Ajouté + supprimé)",
                  child: Chip(
                      backgroundColor: Colors.blue.shade100,
                      avatar: const Icon(Icons.format_line_spacing_rounded),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50))),
                      label: Text(
                        "500",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )))
            ])));
  }
}
