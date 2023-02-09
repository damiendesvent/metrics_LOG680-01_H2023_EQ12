import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../main.dart';

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

class PullAverageTimeToSolve extends StatefulWidget {
  const PullAverageTimeToSolve({super.key});

  @override
  State<PullAverageTimeToSolve> createState() => _PullAverageTimeToSolveState();
}

class _PullAverageTimeToSolveState extends State<PullAverageTimeToSolve> {
  DateTimeRange _selectedDateRange =
      DateTimeRange(start: DateTime(2020, 01, 01), end: DateTime(2040, 01, 01));

  bool maxPeriod = true;
  String sampling = samplings.first;
  String dateString = "sur toute la période";
  List<ChartData> chartData = [];
  double averageLeadTimes = 5;

  void getAverageLeadTimesGraph() {
    chartData.clear();
    List selectedPullRequests = [];
    Map sumPerSampling = {};
    Map nbPerSampling = {};
    for (var task in tasks) {
      String closedAt = task['content']['closedAt'] ?? '';
      if (closedAt.isNotEmpty &&
          _selectedDateRange.start.isBefore(DateTime.parse(closedAt)) &&
          _selectedDateRange.end.isAfter(
              DateTime.parse(closedAt).subtract(const Duration(days: 1))) &&
          task['content']['__typename'] == 'PullRequest') {
        selectedPullRequests.add(
            {'closedAt': closedAt, 'createdAt': task['content']['createdAt']});
      }
      selectedPullRequests.sort((a, b) => DateTime.parse(a['closedAt'])
          .compareTo(DateTime.parse(b['closedAt'])));
    }
    for (var item in selectedPullRequests) {
      String closedAt = item['closedAt'];
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
      Duration leadTime = DateTime.parse(item['closedAt'])
          .difference(DateTime.parse(item['createdAt']));
      if (sumPerSampling.containsKey(closedAt)) {
        sumPerSampling[closedAt] += leadTime;
        nbPerSampling[closedAt]++;
      } else {
        sumPerSampling[closedAt] = leadTime;
        nbPerSampling[closedAt] = 1;
      }
    }
    sumPerSampling.forEach((key, value) => chartData.add(ChartData(
        key,
        value.inMinutes / nbPerSampling[key],
        '${nbPerSampling[key]} pull request')));

    //calculer somme des taches terminees
    num sum = 0;
    sumPerSampling.forEach((key, value) => sum += value.inMinutes);
    setState(() {
      averageLeadTimes = sum / selectedPullRequests.length;
    });
  }

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
    getAverageLeadTimesGraph();
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
  void initState() {
    getAverageLeadTimesGraph();
    super.initState();
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
                  const Icon(Icons.av_timer_rounded, size: 25),
                  const Text("Temps de résolution par"),
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
                        getAverageLeadTimesGraph();
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
                          getAverageLeadTimesGraph();
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
                        'Temps de résolution moyen sur la période : ${averageLeadTimes.round()} min'),
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    format:
                        'point.y minutes, en moyenne, le point.x'),
                series: <ChartSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                  color: Colors.purple,
                  dataSource: chartData,
                  dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.grey, fontSize: 12)),
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelMapper: (ChartData data, _) => data.label)
            ])),
      ))
    ]);
  }
}

/*String averageTime = "5h50";

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: const EdgeInsets.all(15.0),
      child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.av_timer_rounded, size: 25),
                  Text("Temps moyen de résolution d'une pull-request")
                ]),
            Chip(
                avatar: const Icon(Icons.access_time_rounded),
                backgroundColor: Colors.blue.shade100,
                label: Text(
                  "$averageTime", //"5d:5h",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ))
          ]),
    ));
  }*/

class ChartData {
  ChartData(this.x, this.y, this.label);
  final String x;
  final double y;
  final String label;
}
