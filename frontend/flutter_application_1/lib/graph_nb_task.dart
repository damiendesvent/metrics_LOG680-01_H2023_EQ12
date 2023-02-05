import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'main.dart';

class GraphNbTask extends StatefulWidget {
  const GraphNbTask({super.key});

  @override
  State<StatefulWidget> createState() => _GraphNbTask();
}

class _GraphNbTask extends State<GraphNbTask> {
  DateTimeRange? _selectedDateRange;

  var dropdownvalue = columns.first['name'];
  var chipNames = ["Semaine", "Mois", "Max"];
  var dateString = "sur toute la période";
  var nbTacheDone = 50;

  int? selectedIndex = 2;

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

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
    }
    _dateString(_selectedDateRange?.start, _selectedDateRange?.end, "Specific");
    selectedIndex = null;
  }

  void _dateString(DateTime? startDt, DateTime? endDt, String? mode) {
    switch (mode) {
      case "Max":
        {
          dateString = "sur toute la période";
        }
        break;
      case "Mois":
        {
          dateString =
          "du ${DateTime.now().subtract(const Duration(days: 31)).toString().split(' ')[0]} au ${DateTime.now().toString().split(' ')[0]}";
        }
        break;
      case "Semaine":
        {
          dateString =
          "du ${DateTime.now().subtract(const Duration(days: 7)).toString().split(' ')[0]} au ${DateTime.now().toString().split(' ')[0]}";
        }
        break;
      case "Specific":
        {
          String startDate = startDt.toString().split(' ')[0];
          String endDate = endDt.toString().split(' ')[0];
          dateString = "du $startDate au $endDate";
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          children: [
            Card(
                child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 15,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 25),
                        const Text(" Nombre de tâche de "),
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
                              setState(() => dropdownvalue = newValue);
                            },
                          ),
                        ),
                        Text(dateString),
                        ElevatedButton(
                          style: style,
                          onPressed: _show,
                          child: const Icon(Icons.date_range_rounded,
                              color: Colors.white),
                        )
                      ],
                    ))),
            const SizedBox(height: 3.0),
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
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 1.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Text("$nbTacheDone",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700))),
                            const Text("Tâches"),
                            Icon(Icons.check_box_rounded,
                                color: Colors.green.shade600, size: 28)
                          ])))
            ]),
            const SizedBox(height: 3.0),
            Expanded(
                child: Card(
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: SfCartesianChart(
                            title: ChartTitle(text: 'Flutter Chart'),
                            legend: Legend(isVisible: true),
                            tooltipBehavior: TooltipBehavior(enable: true),
                          )),
                    )))
          ],
        ));
  }
}
