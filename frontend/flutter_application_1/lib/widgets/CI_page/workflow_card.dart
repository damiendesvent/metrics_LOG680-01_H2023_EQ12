import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class WorkflowCard extends StatelessWidget {
  WorkflowCard(this.workflow, {super.key});

  Map workflow;
  String workflowName = "";
  int workflowCount = 1;
  int workflowPassCount = 0;

  @override
  Widget build(BuildContext context) {
    workflowName = workflow['name'];
    workflowCount = workflow['count'];
    workflowPassCount = workflow['passCount'];

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
              workflowName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Container(),
          ]),
          TableRow(children: [
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Nombre de run réussis/total",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: const Icon(Icons.functions),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          '$workflowPassCount / $workflowCount',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )))),
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Pourcentage de run réussis",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: const Icon(Icons.percent),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          '${(workflowPassCount * 100 / workflowCount).toStringAsFixed(2)}  %',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ]),
        ]));
  }
}
