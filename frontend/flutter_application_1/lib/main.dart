// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/shared_preferences.dart';
import 'package:flutter_application_1/widgets/tasks_page/task_page.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/tasks_page/columns_nb_task.dart';
import 'api/api.dart';

List tasks = [];
List<Map> columns = [];
int _pageDisplayIndex =
    0; //'0' for the project tasks page and '1' for the pull requests page.
String endTitle = '';
bool showPullRequests = true;

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
      title: 'Tableaux de bord',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tableau de bord : '),
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
      "Dashboard des métriques pour le laboratoire 1 de LOG680\n\nEquipe :\n - Damien Desvent\n - Bruno Moya\n - Dorian Perthuis";

  final List<Widget> _bodyWidgets = [
    const TasksPageLayout(),
    const PullPageLayout()
  ];

  late TextEditingController _projectController = TextEditingController();
  late TextEditingController _ownerController = TextEditingController();
  late TextEditingController _tokenController = TextEditingController();

  late Future<String> _getGithubInitialData;

  String _project = "";
  String _owner = "";
  String _token = "";

  Future<String> getProjectInfos(bool restoreFromPreferences) async {
    print("getProjectInfos called with $restoreFromPreferences");

    if (restoreFromPreferences) {
      // restore the values from the shared preferences //applique le projet par défaut si aucun projet n'est donné
      await SharedApi.getInstance().then((prefs) {
        _projectController.text =
            (prefs.getInt('project_id') ?? '3').toString();
        _ownerController.text =
            prefs.getString('project_owner') ?? 'damiendesvent';
        _tokenController.text = prefs.getString('github_token') ??
            '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';
        //getProjectInfos();
        _token = _tokenController.text;
        _owner = _ownerController.text;
        _project = _projectController.text;
      });
    }

    print(_projectController.text);

    //applique le projet par défaut si aucun projet n'est donné
    // if (_projectController.text.isEmpty &&
    //     _ownerController.text.isEmpty &&
    //     _tokenController.text.isEmpty) {
    //   _projectController = TextEditingController(text: '3');
    //   _ownerController = TextEditingController(text: 'damiendesvent');
    //   _tokenController = TextEditingController(
    //       text: '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');
    // }

    Uri graphQlUri = Uri.parse('https://api.github.com/graphql');

    String query =
        "query{ user(login: \"${_ownerController.text}\") {  projectV2(number: ${_projectController.text}) { ... on ProjectV2 { items(first: 100) { nodes { fieldValues(last: 1) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { name createdAt} } } content { ... on DraftIssue { title body } ... on Issue { __typename title state closedAt assignees(first: 10) { nodes { login } } } ... on PullRequest {__typename title state mergedBy { login } closedAt createdAt commits(last: 200) { totalCount } totalCommentsCount assignees(first: 10) { nodes { name } } } } creator { login } } } } } } } ";

    http.Response response = await http.post(graphQlUri,
        headers: {
          'Authorization': 'Bearer ${_tokenController.text}',
        },
        body: json.encode({
          "query": query,
        }));

    print(query);

    if (response.body.isNotEmpty) {
      var items = json.decode(response.body);
      //print(items);

      if (items['errors'] != null) {
        return Future.error(items['errors'][0]['message']);
      }

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

    return "No project found";
  }

  @override
  void initState() {
    super.initState();
    endTitle = 'tâches du projet';
    _getGithubInitialData = getProjectInfos(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
        appBar: AppBar(
          title: Text(widget.title + endTitle),
          actions: _pageDisplayIndex == 0
              ? [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(width: 0.5)),
                          padding: const EdgeInsets.all(5),
                          child: Row(children: [
                            Switch(
                                value: showPullRequests,
                                onChanged: (value) => setState(() {
                                      showPullRequests = value;
                                    })),
                            const Text(' voir les Pull Request ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black))
                          ])))
                ]
              : null,
        ),
        drawer: _buildDrawer(),
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.displayMedium!,
          textAlign: TextAlign.center,
          child: FutureBuilder<String>(
            future:
                _getGithubInitialData, // a previously-obtained Future<String> or null
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
          DrawerHeader(child: Text(description)),
          Column(children: <Widget>[
            ListTile(
                selected: _pageDisplayIndex == 0,
                leading: const Icon(Icons.task_rounded),
                title: Text("Tâches",
                    style: TextStyle(
                        fontWeight: _pageDisplayIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onTap: () {
                  setState(() {
                    endTitle = 'tâches du projet';
                    _pageDisplayIndex = 0;
                    Navigator.of(context).pop();
                  });
                }),
            ListTile(
                selected: _pageDisplayIndex == 1,
                leading: const Icon(Icons.arrow_circle_down_rounded),
                title: Text("Pull requests",
                    style: TextStyle(
                        fontWeight: _pageDisplayIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onTap: () {
                  setState(() {
                    endTitle = 'métriques des pull requests';
                    showPullRequests = true;
                    getProjectInfos(false);
                    _pageDisplayIndex = 1;
                    Navigator.of(context).pop();
                  });
                }),
          ]),
          _buildProjectIdInput(),
        ],
      ),
    );
  }

  Widget _buildProjectIdInput() {
    // add an input to enter project id and owner name
    // and a button to fetch the data from github
    const Widget spacing = SizedBox(height: 10);
    return Padding(
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
              )),
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
              // check if the given project id and owner name are valid
              // and fetch the data from github
              try {
                String result = await getProjectInfos(
                    false); // false means that the data is not fetched from the shared preferences

                print(result);

                if (result == 'Project found') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Changing to project ${_projectController.text}"),
                    ),
                  );

                  // if the project is found, save the project id and owner name
                  // in the shared preferences
                  SharedApi.saveProjectInfo(int.parse(_projectController.text),
                      _ownerController.text, _tokenController.text);

                  await Api().setProject(int.parse(_projectController.text),
                      _ownerController.text, _tokenController.text);

                  _token = _tokenController.text;
                  _project = _projectController.text;
                  _owner = _ownerController.text;

                  //_getGithubInitialData = getProjectInfos(true);

                  // close the drawer
                  Navigator.of(context).pop();

                  setState(() {
                    //_getGithubInitialData = getProjectInfos(true);
                    print("State set");
                    tasks.clear();
                    columns.clear();

                    _getGithubInitialData = getProjectInfos(true);
                  });
                } else {
                  print("Error: $result");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "$result with project id ${_projectController.text} and owner name ${_ownerController.text}"),
                    ),
                  );
                }
              } catch (e) {
                // close the drawer
                Navigator.of(context).pop();
                print("Error catched: $e");

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "${e} with project id ${_projectController.text} and owner name ${_ownerController.text}"),
                  ),
                );

                // restore the project id and owner name
                _projectController.text = _project.toString();
                _ownerController.text = _owner;
                _tokenController.text = _token;
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
