import 'package:flutter/material.dart';
import '../../main.dart';

bool showPullRequests = true;

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
        child: Row(children: [
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              children: const [
                Icon(Icons.calculate_rounded, size: 25),
                Text("Tâches actives par colonne")
              ]),
          Spacer(),
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 0.5)),
              padding: EdgeInsets.all(5),
              child: Row(children: [
                Switch(
                    value: showPullRequests,
                    onChanged: (value) => setState(() {
                          showPullRequests = value;
                        })),
                Text(' voir les Pull Request ',
                    style: TextStyle(fontWeight: FontWeight.w600))
              ]))
        ]),
      )),
      const SizedBox(height: 3.0),
      Row(
        children: columns.map((Map item) {
          return Expanded(
              child: Card(
                  child: Center(
                      child: Container(
            height: 100,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${item['name']}"),
                Container(
                    height: 30,
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Text("${item['number']}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700))),
              ],
            ),
          ))));
        }).toList(),
      )
    ]);
  }
}
