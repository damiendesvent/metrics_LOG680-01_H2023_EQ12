import '../../main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'task_list.dart';
import 'columns_nb_task.dart';
import 'graph_nb_task.dart';

class TasksPageLayout extends StatefulWidget {
  const TasksPageLayout({super.key});

  @override
  State<TasksPageLayout> createState() => _TasksPageLayoutState();
}

class _TasksPageLayoutState extends State<TasksPageLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Expanded(child: TaskList()),
            const SizedBox(width: 30),
            Expanded(
                child: Column(children: const [
              ColumnsNbTask(),
              SizedBox(height: 30),
              GraphNbTask()
            ]))
          ],
        ));
  }
}
