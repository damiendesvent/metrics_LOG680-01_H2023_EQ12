import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PullAverageComments extends StatefulWidget {
  const PullAverageComments({super.key});

  @override
  State<PullAverageComments> createState() => _PullAverageCommentsState();
}

class _PullAverageCommentsState extends State<PullAverageComments> {
  DateTimeRange _selectedDateRange =
      DateTimeRange(start: DateTime(2020, 01, 01), end: DateTime(2040, 01, 01));

  var dropValue = ["drop1", "drop2", "drop3"];
  bool maxPeriod = true;
  String dateString = "sur toute la période";
  List<ChartData> chartData = [];
  int averageComments = 5;

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31),
        initialDateRange: _selectedDateRange ==
                DateTimeRange(
                    start: DateTime(2020, 01, 01), end: DateTime(2040, 01, 01))
            ? DateTimeRange(start: DateTime(2020, 1, 1), end: DateTime.now())
            : _selectedDateRange,
        currentDate: DateTime.now(),
        saveText: 'Done',
        initialEntryMode: DatePickerEntryMode.inputOnly);

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });
    }
    _dateString(_selectedDateRange.start, _selectedDateRange.end, "Specific");
    maxPeriod = false;
    //setGraph();
  }

  void _dateString(DateTime? startDt, DateTime? endDt, String? mode) {
    switch (mode) {
      case "Max":
        {
          dateString = "sur toute la période";
          maxPeriod = true;
          _selectedDateRange =
              DateTimeRange(start: DateTime(2020, 01, 01), end: DateTime.now());
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
          if (startDt!.isAtSameMomentAs(DateTime(2020, 01, 01)) &&
              endDt!.isAtSameMomentAs(DateTime(2040, 01, 01))) {
            dateString = "sur toute la période";
          } else {
            String startDate = startDt.toString().split(' ')[0];
            String endDate = endDt.toString().split(' ')[0];
            dateString = "du $startDate au $endDate";
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
          child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(15.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 25),
                  const Text("Nombre de commentaires moyen par"),
                  SizedBox(
                    width: 90.0,
                    child: DropdownButtonFormField(
                      value: "drop1",
                      items: dropValue.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {},
                    ),
                  ),
                  Text(dateString),
                  ElevatedButton(
                    style: style,
                    onPressed: _show,
                    child: const Icon(Icons.date_range_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  InputChip(
                      backgroundColor: Colors.grey,
                      label: const Text('Max'),
                      selected: maxPeriod,
                      onSelected: (bool selected) {
                        setState(() {
                          _dateString(_selectedDateRange.start,
                              _selectedDateRange.end, 'Max');
                          //setGraph();
                        });
                      })
                ],
              ))),
      const SizedBox(height: 3.0),
      Card(
          child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(15.0),
        child: Center(
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(
                    text:
                        'Nb commentaires moyen sur la période : $averageComments'),
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    format: 'point.x : point.y tâche(s) terminée(s)'),
                series: <ChartSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y)
            ])),
      ))
    ]);
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}
