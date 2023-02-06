import 'package:flutter/material.dart';
import 'package:flutter_application_1/columns_nb_task.dart';
import 'package:flutter_application_1/task_list.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'graph_nb_task.dart';

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
          "query{ node(id: \"PVT_kwHOBme_us4AKmxQ\") { ... on ProjectV2 { items(first: 20) { nodes { fieldValues(last: 1) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { name createdAt } } } content { ... on DraftIssue { title body } ... on Issue { __typename title state assignees(first: 10) { nodes { login } } } ... on PullRequest {__typename title state assignees(first: 10) { nodes { name } } } } creator { login } } } } } }"
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



