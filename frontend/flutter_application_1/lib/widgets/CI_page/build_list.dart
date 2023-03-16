import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'build_card.dart';
import '../../api/api.dart';
import '../../main.dart';

class BuildList extends StatefulWidget {
  const BuildList({super.key});

  @override
  State<StatefulWidget> createState() => _BuildListState();
}

class _BuildListState extends State<BuildList> {
  DateTimeRange? _selectedDateRange;

  List selectedBuilds = [0, 0, 0];
  var chipNames = ["Semaine", "Mois", "Max", "Aucun"];
  var dateString = "sur toute la période";
  int? selectedIndex = 2;
  List<Widget> cards = [];
  bool init = true;

  @override
  void initState() {
    super.initState();
    updateSelectBuilds();
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

      updateSelectBuilds();
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
    updateSelectBuilds();
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  void updateSelectBuilds() {
    // get cards by column name and date range
    print(_selectedDateRange);
    setState(() {
      selectedBuilds.clear();
      for (Map tag in builds) {
        int buildTime = 0;
        if (_selectedDateRange != null) {
          DateTime createdDateTime = DateTime.parse(tag['tag_last_pushed']);
          if (createdDateTime.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              createdDateTime.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)))) {
            for (Map workflow in workflows) {
              if (workflow['head_sha'] == tag['name'] &&
                  workflow['name'] == 'Docker Image CI') {
                DateTime createdDateTime =
                    DateTime.parse(workflow['created_at']);
                DateTime updatedDateTime =
                    DateTime.parse(workflow['updated_at']);
                buildTime =
                    updatedDateTime.difference(createdDateTime).inSeconds;
              }
            }
            tag['build_time'] = buildTime;
            selectedBuilds.add(tag);
          }
        } else {
          for (Map workflow in workflows) {
            if (workflow['head_sha'] == tag['name'] &&
                workflow['name'] == 'Docker Image CI') {
              DateTime createdDateTime = DateTime.parse(workflow['created_at']);
              DateTime updatedDateTime = DateTime.parse(workflow['updated_at']);
              buildTime = updatedDateTime.difference(createdDateTime).inSeconds;
            }
          }
          tag['build_time'] = buildTime;
          selectedBuilds.add(tag);
        }
      }
    });
  }

  num getAverageBuildTime(List builds) {
    num sum = 0;
    int nbTags = 0;
    for (Map tag in builds) {
      if (tag['build_time'] > 0) {
        sum += tag['build_time'];
        nbTags++;
      }
    }

    return sum / nbTags;
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
              const Icon(Icons.build_rounded, size: 25),
              Text(" Builds $dateString"),
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

          if (selectedBuilds.isNotEmpty)
            Card(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Tooltip(
                        message: "Temps moyen de déploiment",
                        child: Chip(
                            avatar: const Icon(Icons.access_time_rounded),
                            backgroundColor: Colors.blue.shade100,
                            label: Text(
                              '${getAverageBuildTime(selectedBuilds)} s',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )))))
          else
            Card(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Tooltip(
                        message: "Temps moyen de déploiment",
                        child: Chip(
                            avatar: const Icon(Icons.access_time_rounded),
                            backgroundColor: Colors.blue.shade100,
                            label: Text(
                              "Aucune Donnée", //"5d:5h",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )))))
        ]),
        const SizedBox(height: 3),
        if (selectedBuilds.isEmpty)
          const Expanded(child: Center(child: Text("Aucun build")))
        else
          Expanded(
              child: Card(
                  child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(15.0),
                      child: ListView.separated(
                          itemBuilder: (tag, index) =>
                              BuildCard(selectedBuilds[index]),
                          separatorBuilder: (_, index) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: selectedBuilds.length))))
      ],
    );
  }
}
