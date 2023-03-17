import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'workflow_card.dart';
import '../../api/api.dart';
import '../../main.dart';

class WorkflowList extends StatefulWidget {
  const WorkflowList({super.key});

  @override
  State<StatefulWidget> createState() => _WorkflowListState();
}

class _WorkflowListState extends State<WorkflowList> {
  DateTimeRange? _selectedDateRange;

  List selectedWorkflows = [0, 0, 0];
  num totalCount = 1;
  num totalPassCount = 0;
  var chipNames = ["Semaine", "Mois", "Max", "Aucun"];
  var dateString = "sur toute la période";
  int? selectedIndex = 2;
  List<Widget> cards = [];
  bool init = true;

  @override
  void initState() {
    super.initState();
    updateSelectWorkflows();
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31),
        initialDateRange: _selectedDateRange ??
            DateTimeRange(start: DateTime(2020, 1, 1), end: DateTime.now()),
        currentDate: DateTime.now(),
        saveText: 'Done',
        initialEntryMode: DatePickerEntryMode.inputOnly);

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });

      updateSelectWorkflows();
    }

    _dateString(_selectedDateRange?.start, _selectedDateRange?.end, "Specific");
    selectedIndex = null;
  }

  void _dateString(DateTime? startDt, DateTime? endDt, String? mode) {
    switch (mode) {
      case "Max":
        {
          dateString = "sur toute la période";
          _selectedDateRange =
              DateTimeRange(start: DateTime(2020, 01, 01), end: DateTime.now());
        }
        break;
      case "Mois":
        {
          dateString =
              "du ${DateTime.now().subtract(const Duration(days: 31)).toString().split(' ')[0]} au ${DateTime.now().toString().split(' ')[0]}";
          _selectedDateRange = DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 31)),
              end: DateTime.now().add(const Duration(days: 1)));
        }
        break;
      case "Semaine":
        {
          dateString =
              "du ${DateTime.now().subtract(const Duration(days: 7)).toString().split(' ')[0]} au ${DateTime.now().toString().split(' ')[0]}";

          _selectedDateRange = DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now().add(const Duration(days: 1)));
        }
        break;
      case "Specific":
        {
          String startDate = startDt.toString().split(' ')[0];
          String endDate = endDt.toString().split(' ')[0];
          dateString = "du $startDate au $endDate";
          _selectedDateRange = DateTimeRange(
              start: DateTime.parse(startDate), end: DateTime.parse(endDate));
        }
        break;
      case "Aucun": // reset
        {
          dateString = "info directe de github";
          _selectedDateRange = null;
        }
        break;
    }
    updateSelectWorkflows();
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  void updateSelectWorkflows() {
    // get cards by column name and date range
    print(_selectedDateRange);
    setState(() {
      selectedWorkflows.clear();
      for (Map workflow in workflows) {
        if (_selectedDateRange != null) {
          DateTime createdDateTime = DateTime.parse(workflow['created_at']);
          if (createdDateTime.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              createdDateTime.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)))) {
            var myWorkflow = selectedWorkflows.firstWhere(
                (e) => e['name'] == workflow['name'],
                orElse: () => null);
            if (myWorkflow == null) {
              myWorkflow = {
                'name': workflow['name'],
                'count': 1,
                'passCount': workflow['conclusion'] == 'success' ? 1 : 0
              };
              selectedWorkflows.add(myWorkflow);
            } else {
              myWorkflow['count']++;
              myWorkflow['passCount'] +=
                  workflow['conclusion'] == 'success' ? 1 : 0;
            }
          }
        } else {
          var myWorkflow = selectedWorkflows.firstWhere(
              (e) => e['name'] == workflow['name'],
              orElse: () => null);
          if (myWorkflow == null) {
            myWorkflow = {
              'name': workflow['name'],
              'count': 1,
              'passCount': workflow['conclusion'] == 'success' ? 1 : 0
            };
            selectedWorkflows.add(myWorkflow);
          } else {
            myWorkflow['count']++;
            myWorkflow['passCount'] +=
                workflow['conclusion'] == 'success' ? 1 : 0;
          }
        }
      }
      totalCount = 0;
      totalPassCount = 0;
      for (Map workflow in selectedWorkflows) {
        totalCount += workflow['count'];
        totalPassCount += workflow['passCount'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
            child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(15.0),
          child: Wrap(
            spacing: 15,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.horizontal,
            children: [
              const Icon(Icons.directions_run, size: 25),
              Text(" workflows $dateString"),
              ElevatedButton(
                style: style,
                onPressed: _show,
                child:
                    const Icon(Icons.date_range_rounded, color: Colors.white),
              )
            ],
          ),
        )),
        const SizedBox(height: 3),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Card(
                  child: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Wrap(
                        spacing: 15,
                        children: List<Widget>.generate(chipNames.length,
                            (int index) {
                          return InputChip(
                              backgroundColor:
                                  index == 3 ? Colors.red : Colors.grey,
                              label: Text(chipNames[index]),
                              selected: selectedIndex == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selectedIndex != index) {
                                    _dateString(
                                        _selectedDateRange?.start,
                                        _selectedDateRange?.end,
                                        chipNames[index]);
                                    selectedIndex = index;
                                    //updateSelectTasks(dropdownvalue);
                                  }
                                });
                              });
                        }),
                      )))),
          // Card(
          //     child: Container(
          //       padding: const EdgeInsets.all(15.0),
          //       child: ElevatedButton(
          //         onPressed: () {
          //           _dateString(
          //               _selectedDateRange?.start,
          //               _selectedDateRange?.end,
          //               "Reset");
          //           updateSelectTasks(dropdownvalue);
          //         },
          //         child: const Text('Reset'),
          //       ),
          //     )),

          if (selectedWorkflows.isNotEmpty)
            Card(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Tooltip(
                        message: "Total",
                        child: Chip(
                            avatar: const Icon(Icons.functions),
                            backgroundColor: Colors.blue.shade100,
                            label: Text(
                              '$totalPassCount / $totalCount',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            )))))
          else
            Card(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Tooltip(
                        message: "Total",
                        child: Chip(
                            avatar: const Icon(Icons.access_time_rounded),
                            backgroundColor: Colors.blue.shade100,
                            label: const Text(
                              "Aucune Donnée", //"5d:5h",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )))))
        ]),
        const SizedBox(height: 3),
        if (selectedWorkflows.isEmpty)
          const Expanded(child: Center(child: Text("Aucun workflow")))
        else
          Expanded(
              child: Card(
                  child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(15.0),
                      child: ListView.separated(
                          itemBuilder: (tag, index) =>
                              WorkflowCard(selectedWorkflows[index]),
                          separatorBuilder: (_, index) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: selectedWorkflows.length))))
      ],
    );
  }
}
