import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PullOpenClose extends StatefulWidget {
  const PullOpenClose({super.key});

  @override
  State<PullOpenClose> createState() => _PullOpenCloseState();
}

class _PullOpenCloseState extends State<PullOpenClose> {
  double closePourcentage =
      0.2; //[0,1] : Cette valeur update automatique l'ui si elle est modifier.
  var redTextStyle = TextStyle(
      color: Color(0xffFF2F2F), fontWeight: FontWeight.w600, fontSize: 15);
  var greenTextStyle = TextStyle(
      color: Color(0xff00DB09), fontWeight: FontWeight.w600, fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: const EdgeInsets.all(15.0),
            width: double.maxFinite,
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline_rounded),
                        Text(
                            "Rapport entre le nombre de pull-request fermé et ouverte"),
                      ]),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: [
                      Text("${(closePourcentage) * 100}%", style: redTextStyle),
                      DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xffFF2F2F),
                                  Color(0xffFF2F2F),
                                  Color(0xff00DB09),
                                  Color(0xff00DB09)
                                ],
                                stops: [
                                  0,
                                  closePourcentage,
                                  closePourcentage,
                                  1
                                ]),
                          ),
                          child: SizedBox(height: 20, width: 80)),
                      Text("${(1 - closePourcentage) * 100}%",
                          style: greenTextStyle)
                    ],
                  )
                ])));
  }
}
