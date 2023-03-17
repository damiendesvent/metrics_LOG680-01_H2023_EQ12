import '../../main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int nbWorkflow = workflows.length;

class WorkflowNb extends StatefulWidget {
  const WorkflowNb({super.key});

  @override
  State<WorkflowNb> createState() => _WorkflowNbState();
}

class _WorkflowNbState extends State<WorkflowNb> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.numbers_rounded, size: 25),
                  Text("Nombre de runs du Workflow")
                ]),
            Container(
                height: 30,
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Text("$nbWorkflow",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)))
          ]),
    ));
  }
}
