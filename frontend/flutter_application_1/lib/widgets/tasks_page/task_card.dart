import 'dart:convert';

import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  TaskCard(this.task, this.customCard, {super.key});

  Map task;
  bool customCard =
      false; // if true, json is different than orignial github json as it comes from our api

  var chipNames = [];
  String taskName = "";
  String status = "";
  String creatorName = "";
  String createdAt = "";
  String taskType = "";
  String columnName = "";

  String leadTime = "Aucune Donnée";

  @override
  Widget build(BuildContext context) {
    if (!customCard) {
      taskName = task['content']['title'];
      columnName = task['fieldValues']['nodes'][0]['name'];
      status = task['content']['state'];
      taskType = "- " + task['content']['__typename'];

      task['content']['assignees']['nodes']
          .forEach((assignee) => chipNames.add(assignee['login'] ?? ''));
      creatorName = task['creator']['login'];
      createdAt = task['fieldValues']['nodes'][0]['createdAt'].substring(
          0, task['fieldValues']['nodes'][0]['createdAt'].indexOf('T'));
    } else {
      // decode task name to utf8 to display emojis correctly
      taskName = utf8.decode(task['name'].toString().codeUnits);

      columnName = task['column_name'];
      //taskName = task['name'];

      if (task['type_name'] == 'Issue') {
        status = task['state'];
      } else {
        status = task['pull_state'];
      }

      // parse assignee as a python list []
      String assignee = task['assignees'];
      assignee = assignee.substring(1, assignee.length - 1);
      List<String> assigneeList = assignee.split(',');

      /* ancienne version pour les chipNames
      assigneeName = utf8.decode(assigneeList[0].toString().codeUnits);

      // remove quotes from assignee name
      assigneeName = assigneeName.replaceAll("'", '');

      if (assigneeName.isNotEmpty && !chipNames.contains(assigneeName)) {
        chipNames.add(assigneeName);
      }*/

      //nouvelle version
      assigneeList.forEach((assigneeName) => chipNames.add(
          utf8.decode(assigneeName.toString().codeUnits).replaceAll("'", '')));

      creatorName = utf8.decode(task['creator'].toString().codeUnits);
      createdAt =
          task['created_at'].substring(0, task['created_at'].indexOf('T'));

      double leadTimeSeconds = task['lead_time'];

      if (leadTimeSeconds > 0) {
        int days = (leadTimeSeconds / 86400).floor();
        int hours = ((leadTimeSeconds % 86400) / 3600).floor();
        int minutes = (((leadTimeSeconds % 86400) % 3600) / 60).floor();
        int seconds = (((leadTimeSeconds % 86400) % 3600) % 60).floor();

        leadTime = "${days}d:${hours}h:${minutes}m";
      }

      taskType = "- " + task['type_name'];
    }

    return Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: const Color.fromRGBO(191, 191, 191, 1), width: 1)),
        child: Table(columnWidths: const {
          1: FractionColumnWidth(0.25)
        }, children: [
          TableRow(children: [
            Text(
              taskName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Container(
                alignment: Alignment.centerRight,
                child: Text("$status $taskType - $columnName"))
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
            Wrap(
              spacing: 5,
              children: List<Widget>.generate(chipNames.length, (int index) {
                return Chip(
                    label: Text(chipNames[index],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.amber);
              }),
            ),
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Temps de complétion",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: const Icon(Icons.access_time_rounded),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          leadTime,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ])
        ]));
  }
}
