import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

List tasks = [];
List<Map> columns = [];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau des métriques',
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
  void getProjectInfos() async {
    Uri graphQlUri = Uri.parse('https://api.github.com/graphql');

    http.Response response = await http.post(graphQlUri,
        headers: {
          'Authorization': 'Bearer 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',
        },
        body: json.encode({
          "query":
              "query{ node(id: \"PVT_kwHOBme_us4AKmxQ\") { ... on ProjectV2 { items(first: 20) { nodes { fieldValues(last: 1) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { name createdAt } } } content { ... on DraftIssue { title body } ... on Issue { title assignees(first: 10) { nodes { login } } } ... on PullRequest { title assignees(first: 10) { nodes { name } } } } creator { login } } } } } }"
        }));
    /*String response_body =
        '{ "data": { "node": { "items": { "nodes": [ { "fieldValues": { "nodes": [ { "name": "Done ✅", "createdAt": "2023-01-13T15:06:52Z" } ] }, "content": { "title": "Test issue", "assignees": { "nodes": [] } }, "creator": { "login": "elblogbruno" } }, { "fieldValues": { "nodes": [ { "name": "Done ✅", "createdAt": "2023-01-13T15:22:56Z" } ] }, "content": { "title": "test modèle issue", "assignees": { "nodes": [] } }, "creator": { "login": "damiendesvent" } }, { "fieldValues": { "nodes": [ { "name": "In progress 🛠️", "createdAt": "2023-01-18T15:00:36Z" } ] }, "content": { "title": "[FEATURE] Création de l\'UI de visualisation des métriques", "assignees": { "nodes": [ { "login": "Dorian-Perthuis" } ] } }, "creator": { "login": "damiendesvent" } }, { "fieldValues": { "nodes": [ { "name": "In progress 🛠️", "createdAt": "2023-01-23T00:19:11Z" } ] }, "content": { "title": "[FEATURE] Création des requêtes d\'import des métriques", "assignees": { "nodes": [ { "login": "damiendesvent" } ] } }, "creator": { "login": "damiendesvent" } }, { "fieldValues": { "nodes": [ { "name": "In progress 🛠️", "createdAt": "2023-01-18T15:02:49Z" } ] }, "content": { "title": "[FEATURE] Création de la base de données", "assignees": { "nodes": [ { "login": "elblogbruno" } ] } }, "creator": { "login": "damiendesvent" } }, { "fieldValues": { "nodes": [ { "name": "To do ⏲️", "createdAt": "2023-01-18T14:54:34Z" } ] }, "content": { "title": "[FEATURE] Création de l\'API Rest", "assignees": { "nodes": [] } }, "creator": { "login": "damiendesvent" } }, { "fieldValues": { "nodes": [ { "name": "Review 👀", "createdAt": "2023-01-23T00:25:59Z" } ] }, "content": { "title": "feat: started flutter project", "assignees": { "nodes": [] } }, "creator": { "login": "damiendesvent" } } ] } } } }';
    */
    if (response.body.isNotEmpty) {
      var items = json.decode(response.body);

      setState(() {
        tasks = items['data']['node']['items']['nodes'];
      });

      //boucle permettant de remplir le tableau items avec les colonnes du kanban
      for (var task in tasks) {
        String status = task['fieldValues']['nodes'][0]['name'];
        int indexStatus = -1;
        for (var item in columns) {
          indexStatus =
              item['name'] == status ? columns.indexOf(item) : indexStatus;
        }
        if (indexStatus != -1) {
          setState(() {
            columns[indexStatus]['number'] += 1;
          });
        } else {
          setState(() {
            columns.add({'name': status, 'number': 1});
          });
        }
      }
      columns.sort((a, b) => b['number'].compareTo(
          a['number'])); //tri du plus grand nombre de tâches au plus petit
    }
  }

  @override
  void initState() {
    super.initState();
    getProjectInfos();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        return Scaffold(
            backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Container(
                padding: const EdgeInsets.all(20.0),
                child: snapshot.hasData && tasks.isNotEmpty
                    ? Row(
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
                      )
                    : const Center(child: CircularProgressIndicator())));
      });

  Future<bool> fetchData() => Future.delayed(const Duration(seconds: 1), () {
        return true;
      });
}

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

  void updateSelectTasks(var columnName) {
    setState(() {
      selectedTasks.clear();
      for (var task in tasks) {
        if (task['fieldValues']['nodes'][0]['name'] == columnName) {
          selectedTasks.add(task);
        }
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
        Expanded(
            child: Card(
                child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    child: ListView.separated(
                        itemBuilder: (task, index) =>
                            TaskCard(selectedTasks[index]),
                        separatorBuilder: (_, index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: selectedTasks.length))))
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
            children: const [
              Icon(Icons.calculate_rounded, size: 25),
              Text("Nombre de tâche actif par colonne")
            ]),
      )),
      const SizedBox(height: 3.0),
      Row(
        children: columns.map((Map item) {
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black54, width: 1.5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text("${item['number']}",
                                      style: const TextStyle(
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

class TaskCard extends StatelessWidget {
  TaskCard(this.task, {super.key});

  Map task;

  var chipNames = [];
  String taskName = "";
  String status = "";
  String assigneeName = "";
  String creatorName = "";
  String createdAt = "";

  @override
  Widget build(BuildContext context) {
    taskName = task['content']['title'];
    status = task['fieldValues']['nodes'][0]['name'];
    assigneeName = task['content']['assignees']['nodes'].isEmpty
        ? ""
        : task['content']['assignees']['nodes'][0]['login'];
    if (assigneeName.isNotEmpty && !chipNames.contains(assigneeName)) {
      chipNames.add(assigneeName);
    }
    creatorName = task['creator']['login'];
    createdAt = task['fieldValues']['nodes'][0]['createdAt'].substring(
        0, task['fieldValues']['nodes'][0]['createdAt'].indexOf('T'));
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
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Container(alignment: Alignment.centerRight, child: Text(status))
          ]),
          TableRow(children: [
            Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                child: Text(
                  "Créé par $creatorName le $createdAt",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
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
                        avatar: const Icon(Icons.access_time_rounded),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            side: BorderSide(
                                color: Colors.grey.shade600, width: 1)),
                        label: const Text(
                          "5d:5h",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ))))
          ])
        ]));
  }
}
