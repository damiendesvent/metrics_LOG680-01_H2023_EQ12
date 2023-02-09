import '../../main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_nb_en_attente.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_average_time_to_solve.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_rq_closed_open.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_nb_average_comments.dart';
import 'package:flutter_application_1/widgets/pull_requests_page/pull_average_size.dart';

class PullPageLayout extends StatefulWidget {
  const PullPageLayout({super.key});

  @override
  State<PullPageLayout> createState() => _PullPageLayout();
}

class _PullPageLayout extends State<PullPageLayout> {
  void getPullRequestsInfo() {
    nbPullRequestWaiting = 0;
    int nbPullRequestClosed = 0;
    //averageSize = 0;
    int sumSize = 0;
    for (var task in tasks) {
      if (task['content']['__typename'] == 'PullRequest') {
        task['content']['state'] == 'OPEN'
            ? nbPullRequestWaiting++
            : nbPullRequestClosed++;
        sumSize +=
            int.parse(task['content']['commits']['totalCount'].toString());
      }
    }
    closePourcentage =
        nbPullRequestWaiting / (nbPullRequestWaiting + nbPullRequestClosed);
    averageSize = sumSize / (nbPullRequestWaiting + nbPullRequestClosed);
  }

  @override
  void initState() {
    getPullRequestsInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Row(children: const [
            Expanded(child: PullNbEnAttente()),
            Expanded(child: PullAverageSize()),
          ]),
          const PullOpenClose(),
          const SizedBox(height: 30),
          Row(
            children: const [
              Expanded(
                child: PullAverageTimeToSolve(),
              ),
              Expanded(child: PullAverageComments()),
            ],
          )
        ]));
  }
}
