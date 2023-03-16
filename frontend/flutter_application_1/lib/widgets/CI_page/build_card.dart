import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class BuildCard extends StatelessWidget {
  BuildCard(this.tag, {super.key});

  Map tag;
  String buildName = "";
  String creatorName = "";
  String createdAt = "";
  String buildSize = "";
  String branchName = "";
  String buildTime = "";

  @override
  Widget build(BuildContext context) {
    buildName = tag['name'];
    creatorName = tag['last_updater_username'];
    createdAt = tag['tag_last_pushed']
        .replaceAll('T', ' à ')
        .substring(0, tag['tag_last_pushed'].indexOf('.') + 2);
    buildSize = '${(tag['full_size'] / pow(2, 20)).toStringAsFixed(2)} Mo';
    for (Map workflow in workflows) {
      if (workflow['head_sha'] == buildName &&
          workflow['name'] == 'Docker Image CI') {
        branchName = workflow['display_title'];
        DateTime createdDateTime = DateTime.parse(workflow['created_at']);
        DateTime updatedDateTime = DateTime.parse(workflow['updated_at']);
        buildTime =
            '${updatedDateTime.difference(createdDateTime).inSeconds} s';
      }
    }
    // permet d'ajouter les infos à la build latest
    if (branchName.isEmpty) {
      branchName = workflows[0]['display_title'];
    }
    if (buildTime.isEmpty) {
      DateTime createdDateTime = DateTime.parse(workflows[1]['created_at']);
      DateTime updatedDateTime = DateTime.parse(workflows[1]['updated_at']);
      buildTime = '${updatedDateTime.difference(createdDateTime).inSeconds} s';
    }

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
                        )))),
          ]),
          TableRow(children: [
            Wrap(children: [
              Chip(
                  label: Text(branchName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.pink.shade100)
            ]),
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Taille de l'image",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: const Icon(Icons.storage),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          buildSize,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ]),
        ]));
  }
}
