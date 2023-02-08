import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'main.dart';

List<String> samplings = ['jour', 'semaine', 'mois'];
List<String> months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre'
];

class GraphNbTask extends StatefulWidget {
  const GraphNbTask({super.key});

  @override
  State<StatefulWidget> createState() => _GraphNbTask();
}

class _GraphNbTask extends State<GraphNbTask> {
  DateTimeRange _selectedDateRange =
      DateTimeRange(start: DateTime(2020, 01, 01), end: DateTime(2040, 01, 01));

  String sampling = samplings.first;
  List<String> chipNames = ["Semaine", "Mois", "Max"];
  String dateString = "sur toute la période";
  int nbTacheDone = 0;
  bool maxPeriod = true;
  List<ChartData> chartData = [];

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
    setGraph();
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

  void setGraph() {
    chartData.clear();
    List selectedTasks = [];
    Map nbPerSampling = {};
    for (var task in tasks) {
      String closedAt = task['content']['closedAt'] ?? '';
      if (closedAt.isNotEmpty &&
          _selectedDateRange.start.isBefore(DateTime.parse(closedAt)) &&
          _selectedDateRange.end.isAfter(
              DateTime.parse(closedAt).subtract(const Duration(days: 1)))) {
        selectedTasks.add(closedAt);
      }
      selectedTasks
          .sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
    }
    for (var closedAt in selectedTasks) {
      switch (sampling) {
        case "jour":
          DateTime closedAtDate = DateTime.parse(closedAt);
          closedAt =
              '${closedAtDate.day} ${months[closedAtDate.month - 1]} ${closedAtDate.year}';
          break;
        case "semaine":
          int weekDay = DateTime.parse(closedAt).weekday;
          DateTime mondayClosedAt =
              DateTime.parse(closedAt).subtract(Duration(days: weekDay - 1));
          closedAt =
              'semaine du ${mondayClosedAt.day} ${months[mondayClosedAt.month - 1]}';
          break;
        case "mois":
          closedAt = months[DateTime.parse(closedAt).month - 1];
          break;
      }
      if (nbPerSampling.containsKey(closedAt)) {
        nbPerSampling[closedAt] += 1;
      } else {
        nbPerSampling[closedAt] = 1;
      }
    }
    nbPerSampling.forEach((key, value) => chartData.add(ChartData(key, value)));

    //calculer somme des taches terminees
    num sum = 0;
    nbPerSampling.forEach((key, value) => sum += value);
    setState(() {
      nbTacheDone = sum.toInt();
    });
  }

  @override
  void initState() {
    setGraph();
    super.initState();
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
                    const Text(" Tâches terminées par"),
                    SizedBox(
                      width: 90.0,
                      child: DropdownButtonFormField(
                        value: sampling,
                        items: samplings.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => sampling = newValue!);
                          setGraph();
                        },
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
                            setGraph();
                          });
                        })
                  ],
                ))),
        const SizedBox(height: 3.0),
        Expanded(
            child: Card(
                child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(15.0),
          child: Center(
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(
                      text: 'Tâches terminées sur la période : $nbTacheDone'),
                  tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      format: 'point.x : point.y tâches terminées'),
                  series: <ChartSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y)
              ])),
        )))
      ],
    ));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}
