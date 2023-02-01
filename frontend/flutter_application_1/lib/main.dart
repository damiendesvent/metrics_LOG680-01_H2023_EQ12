import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Tableau des métriques'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
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
            )));
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DateTimeRange? _selectedDateRange;

  String dropdownvalue = 'drop1';
  var items = ["drop1", "drop2", "drop3"];
  var tasks = ["", "", ""];
  var chipNames = ["Semaine", "Mois", "Max"];
  var dateString = "sur toute la période";

  int? selectedIndex = 2;

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
      print(result.start.toString());
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

  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

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
              Icon(Icons.view_list_rounded, size: 25),
              const Text(" Tâche de "),
              Container(
                width: 150.0,
                child: DropdownButtonFormField(
                  value: dropdownvalue,
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => dropdownvalue = newValue!);
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
                  padding: EdgeInsets.all(15.0),
                  child: Tooltip(
                      message: "Lead time moyen",
                      child: Chip(
                          avatar: Icon(Icons.access_time_rounded),
                          backgroundColor: Colors.blue.shade100,
                          label: Text(
                            "5d:5h",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )))))
        ]),
        const SizedBox(height: 3),
        Expanded(
            child: Card(
                child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    child: ListView.separated(
                        itemBuilder: (tasks, index) => TaskCard(),
                        separatorBuilder: (_, index) {
                          return SizedBox(height: 10);
                        },
                        itemCount: tasks.length))))
      ],
    );
  }
}

class ColumnsNbTask extends StatefulWidget {
  const ColumnsNbTask({super.key});

  @override
  State<StatefulWidget> createState() => _ColumnsNbTask();
}

class _ColumnsNbTask extends State<ColumnsNbTask> {
  var items = [
    {'name': 'item1', 'number': 5},
    {'name': 'item2', 'number': 2},
    {'name': 'item3', 'number': 10},
    {'name': 'item4', 'number': 10},
    {'name': 'item5', 'number': 10},
    {'name': 'item6', 'number': 10}
  ];

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
              Icon(Icons.calculate_rounded, size: 25),
              const Text("Nombre de tâche actif par colonne")
            ]),
      )),
      const SizedBox(height: 3.0),
      Row(
        children: items.map((Map item) {
          return Expanded(
              child: Card(
                  child: Center(
                      child: Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            direction: Axis.vertical,
                            children: [
                              Text("${item['name']}"),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black54, width: 1.5),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text("${item['number']}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700))),
                            ],
                          )))));
        }).toList(),
      )
    ]);
  }
}

class GraphNbTask extends StatefulWidget {
  const GraphNbTask({super.key});

  @override
  State<StatefulWidget> createState() => _GraphNbTask();
}

class _GraphNbTask extends State<GraphNbTask> {
  DateTimeRange? _selectedDateRange;

  String dropdownvalue = 'drop1';
  var items = ["drop1", "drop2", "drop3"];
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
      print(result.start.toString());
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
        child: Container(
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
                    Icon(Icons.calendar_month_rounded, size: 25),
                    Text(" Nombre de tâche de "),
                    Container(
                      width: 150.0,
                      child: DropdownButtonFormField(
                        value: dropdownvalue,
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => dropdownvalue = newValue!);
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
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black54, width: 1.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text("$nbTacheDone",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700))),
                        Text("Tâches"),
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
    )));
  }
}

class TaskCard extends StatelessWidget {
  TaskCard({super.key});

  var chipNames = ['chip1', 'chip2'];
  var taskName = "Nom de la tâche !";
  var creatorName = "Jean dupond";

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: const Color.fromRGBO(191, 191, 191, 1), width: 1)),
        child: Table(columnWidths: const {
          1: FractionColumnWidth(0.25)
        }, children: [
          TableRow(children: [
            Text(
              taskName,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Container(
                alignment: Alignment.centerRight, child: Text("In progress"))
          ]),
          TableRow(children: [
            Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                child: Text(
                  "Créer par ${creatorName} le __/__/____",
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                )),
            Container()
          ]),
          TableRow(children: [
            Wrap(
              spacing: 5,
              children: List<Widget>.generate(chipNames.length, (int index) {
                return Chip(
                    label: Text(chipNames[index],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.amber);
              }),
            ),
            Container(
                alignment: Alignment.centerRight,
                child: Tooltip(
                    message: "Temps de complétion",
                    child: Chip(
                        backgroundColor: Colors.transparent,
                        avatar: Icon(Icons.access_time_rounded),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: Text(
                          "5d:5h",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ])
        ]));
  }
}
