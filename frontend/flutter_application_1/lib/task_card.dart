import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  TaskCard(this.task, this.customCard, {super.key});

  Map task;
  bool customCard = false; // if true, json is different than orignial github json as it comes from our api

  var chipNames = [];
  String taskName = "";
  String status = "";
  String assigneeName = "";
  String creatorName = "";
  String createdAt = "";

  @override
  Widget build(BuildContext context) {
    taskName = task['content']['title'];
    status = task['fieldValues']['nodes'][0]['name'];
    assigneeName = task['content']['assignees']['nodes'].isEmpty
        ? ""
        : task['content']['assignees']['nodes'][0]['login'];
    if (assigneeName.isNotEmpty && !chipNames.contains(assigneeName)) {
      chipNames.add(assigneeName);
    }
    creatorName = task['creator']['login'];
    createdAt = task['fieldValues']['nodes'][0]['createdAt'].substring(
        0, task['fieldValues']['nodes'][0]['createdAt'].indexOf('T'));
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
            Container(alignment: Alignment.centerRight, child: Text(status))
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
                        label: const Text(
                          "5d:5h",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ])
        ]));
  }
}
