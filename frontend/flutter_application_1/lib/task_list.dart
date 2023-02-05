import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/task_card.dart';

import 'api.dart';
import 'main.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<StatefulWidget> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DateTimeRange? _selectedDateRange;

  List selectedTasks = [];
  var dropdownvalue = columns.first['name'];
  var chipNames = ["Semaine", "Mois", "Max"];
  var dateString = "sur toute la période";
  int? selectedIndex = 2;
  List<Widget> cards = [];
  bool init = true;

  bool isCustomCard = false;

  @override
  void initState() {
    super.initState();
    updateSelectTasks(dropdownvalue);
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31),
        initialDateRange:
            DateTimeRange(start: DateTime(2020, 1, 1), end: DateTime.now()),
        currentDate: DateTime.now(),
        saveText: 'Done',
        initialEntryMode: DatePickerEntryMode.inputOnly);

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });

      updateSelectTasks(dropdownvalue);
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
          _selectedDateRange = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 31)), end: DateTime.now().add(const Duration(days: 1)));
        }
        break;
      case "Semaine":
        {
          dateString =
          "du ${DateTime.now().subtract(const Duration(days: 7)).toString().split(' ')[0]} au ${DateTime.now().toString().split(' ')[0]}";

          _selectedDateRange = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now().add(const Duration(days: 1)));
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
    }
    updateSelectTasks(dropdownvalue);
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  void updateSelectTasks(var columnName) {
    // TODO: contact api to get tasks with column name
    print("updateSelectTasks: " + columnName);

    // get cards by column name and date range
    print(_selectedDateRange);
    if (_selectedDateRange != null)
    {
        Api().getCardsByColumnAndTimeRange(columnName, _selectedDateRange!).then((
            value) {
          //print("value: $value");

          // parse string to json
          dynamic x2 = jsonDecode(value);
          print("x2: $x2");

          selectedTasks.clear();
          // add cards to list
          for (var i = 0; i < x2['cards'].length; i++) {
            selectedTasks.add(x2['cards'][i]);
          }
          print("selectedTasks: $selectedTasks");

          setState(() {

            isCustomCard = true;
          });

        });
    }else {
      setState(() {
        selectedTasks.clear();
        for (var task in tasks) {
          if (task['fieldValues']['nodes'][0]['name'] == columnName) {
            selectedTasks.add(task);
          }
        }
        isCustomCard = false;
      });
    }
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
              const Icon(Icons.view_list_rounded, size: 25),
              const Text(" Tâche de "),
              SizedBox(
                width: 150.0,
                child: DropdownButtonFormField(
                  value: dropdownvalue,
                  items: columns.map((Map item) {
                    return DropdownMenuItem(
                      value: item['name'],
                      child: Text(item['name']),
                    );
                  }).toList(),
                  onChanged: (var newValue) {
                    setState(() {
                      dropdownvalue = newValue;
                      updateSelectTasks(dropdownvalue);
                    });
                  },
                ),
              ),
              Text(dateString),
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
                                  }
                                });
                              });
                        }),
                      )))),
          Card(
              child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Tooltip(
                      message: "Lead time moyen",
                      child: Chip(
                          avatar: const Icon(Icons.access_time_rounded),
                          backgroundColor: Colors.blue.shade100,
                          label: const Text(
                            "5d:5h",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )))))
        ]),
        const SizedBox(height: 3),
        if (selectedTasks.isEmpty)
          Expanded(child: Center(child: const Text("Aucune tâche")))
        else
        Expanded(
            child: Card(
                child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    child: ListView.separated(
                        itemBuilder: (task, index) =>
                            TaskCard(selectedTasks[index], isCustomCard),
                        separatorBuilder: (_, index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: selectedTasks.length))))
      ],
    );
  }
}
