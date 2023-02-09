import 'package:flutter/material.dart';
import 'package:flutter_application_1/columns_nb_task.dart';
import 'package:flutter_application_1/api/shared_preferences.dart';
import 'package:flutter_application_1/task_list.dart';
import 'package:flutter_application_1/task_page.dart';
import 'package:flutter_application_1/pull_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api.dart';
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
  String description =
      "Dashboard des métriques pour le laboratoire 1 de LOG680\n\nEquipe :\n - Damien\n - Bruno\n - Dorian Perthuis";

  int _pageDisplayIndex =
      0; //'0' for the project tasks page and '1' for the pull requests page.
  final List<Widget> _bodyWidgets = [TasksPageLayout(), PullPageLayout()];

  late TextEditingController _projectController;
  late TextEditingController _ownerController;
  late TextEditingController _tokenController;

  Future<String> getProjectInfos() async {
    print("getProjectInfos called !");

    //applique le projet par défaut si aucun projet n'est donné
    if (_projectController.text.isEmpty &&
        _ownerController.text.isEmpty &&
        _tokenController.text.isEmpty) {
      _projectController = TextEditingController(text: '3');
      _ownerController = TextEditingController(text: 'damiendesvent');
      _tokenController = TextEditingController(
          text: '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');
    }
    print(_ownerController.text);
    Uri graphQlUri = Uri.parse('https://api.github.com/graphql');

    String query =
        "query{ user(login: \"${_ownerController.text}\") {  projectV2(number: ${_projectController.text}) { ... on ProjectV2 { items(first: 100) { nodes { fieldValues(last: 1) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { name createdAt} } } content { ... on DraftIssue { title body } ... on Issue { __typename title state closedAt assignees(first: 10) { nodes { login } } } ... on PullRequest {__typename title state closedAt assignees(first: 10) { nodes { name } } } } creator { login } } } } } } } ";

    http.Response response = await http.post(graphQlUri,
        headers: {
          'Authorization': 'Bearer ${_tokenController.text}',
        },
        body: json.encode({
          "query": query,
        }));

    if (response.body.isNotEmpty) {
      var items = json.decode(response.body);
      print(items);

      if (items['message'] != null) {
        return Future.error(items['message']);
      }

      if (items['data']['user']['projectV2'] == null) {
        return Future.error("No project found");
      }

      tasks = items['data']['user']['projectV2']['items']['nodes'];

      //boucle permettant de remplir le tableau items avec les colonnes du kanban
      columns.clear();
      for (var task in tasks) {
        String status = task['fieldValues']['nodes'][0]['name'];
        int indexStatus = -1;
        for (var item in columns) {
          indexStatus =
              item['name'] == status ? columns.indexOf(item) : indexStatus;
        }
        if (indexStatus != -1) {
          columns[indexStatus]['number'] += 1;
        } else {
          columns.add({'name': status, 'number': 1});
        }
      }

      columns.sort((a, b) => b['number'].compareTo(
          a['number'])); //tri du plus grand nombre de tâches au plus petit

      return "Project found";
    }

    return Future.error("No project found");
  }

  @override
  void initState() {
    super.initState();
    _projectController = TextEditingController(text: '3');
    _ownerController = TextEditingController(text: 'damiendesvent');
    _tokenController =
        TextEditingController(text: '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');

    // restore the values from the shared preferences
    SharedPreferences.getInstance().then((prefs) {
      _projectController.text = (prefs.getInt('project_id') ?? '').toString();
      _ownerController.text = prefs.getString('project_owner') ?? '';
      _tokenController.text = prefs.getString('github_token') ?? '';
      //getProjectInfos();
    });
  }

  // @override
  // Widget build(BuildContext context) => FutureBuilder(
  //     future: getProjectInfos(),
  //     builder: (context, snapshot) {
  //       return Scaffold(
  //           backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
  //           appBar: AppBar(
  //             title: Text(widget.title),
  //           ),
  //           drawer: _buildDrawer(),
  //           body: Container(
  //               padding: const EdgeInsets.all(20.0),
  //               child: snapshot.hasData && tasks.isNotEmpty
  //                   ? _bodyWidgets.elementAt(_pageDisplayIndex)
  //                   : const Center(child: CircularProgressIndicator())));
  //     });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: _buildDrawer(),
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.displayMedium!,
          textAlign: TextAlign.center,
          child: FutureBuilder<String>(
            future:
                getProjectInfos(), // a previously-obtained Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: tasks.isNotEmpty
                        ? _bodyWidgets.elementAt(_pageDisplayIndex)
                        : const Text('No project found'));
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
        ));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(child: DrawerHeader(child: Text("$description"))),
          Container(
            child: Column(children: <Widget>[
              ListTile(
                  leading: Icon(Icons.task_rounded),
                  title: Text("Tâches"),
                  onTap: () {
                    setState(() {
                      _pageDisplayIndex = 0;
                      Navigator.of(context).pop();
                    });
                  }),
              ListTile(
                  leading: Icon(Icons.arrow_circle_down_rounded),
                  title: Text("Pull requests"),
                  onTap: () {
                    setState(() {
                      _pageDisplayIndex = 1;
                      Navigator.of(context).pop();
                    });
                  }),
            ]),
          ),
          _buildProjectIdInput(),
        ],
      ),
    );
  }

  Widget _buildProjectIdInput() {
    // add an input to enter project id and owner name
    // and a button to fetch the data from github
    const Widget spacing = SizedBox(height: 10);
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _projectController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project ID',
              ),
            ),
            spacing,
            TextField(
              controller: _ownerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Owner Name',
              ),
            ),
            spacing,
            TextField(
              obscureText: true,
              controller: _tokenController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Github Token',
              ),
            ),
            spacing,
            ElevatedButton(
              onPressed: () async {
                SharedApi.saveProjectInfo(int.parse(_projectController.text),
                    _ownerController.text, _tokenController.text);
                await Api().setProject(int.parse(_projectController.text),
                    _ownerController.text, _tokenController.text);

                getProjectInfos();

                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
