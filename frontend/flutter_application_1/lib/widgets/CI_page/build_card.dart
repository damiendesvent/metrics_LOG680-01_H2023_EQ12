import 'dart:convert';

import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  BuildCard({super.key});
  String buildName = "buildNAme";
  String creatorName = "Dorian Perthuis";
  String createdAt = "24/12/2022";
  String buildTime = "100";
  String branchName = "Branch-Name";

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade400, width: 1)),
        child: Table(columnWidths: const {
          1: FractionColumnWidth(0.25)
        }, children: [
          TableRow(children: [
            Text(
              buildName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Container()
          ]),
          TableRow(children: [
            Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                child: Text(
                  "Créé par $creatorName le $createdAt",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                )),
            Container()
          ]),
          TableRow(children: [
            Wrap(children: [
              Chip(
                  avatar: const Icon(Icons.merge_rounded),
                  label: Text(branchName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.pink.shade100)
            ]),
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Temps de build",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: const Icon(Icons.handyman_rounded),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          buildTime,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ])
        ]));
  }
}
