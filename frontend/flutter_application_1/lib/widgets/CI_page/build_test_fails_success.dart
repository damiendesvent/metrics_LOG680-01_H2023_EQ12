import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double failPourcentage = 0.2;

class BuildTestSuccess extends StatefulWidget {
  const BuildTestSuccess({super.key});

  @override
  State<BuildTestSuccess> createState() => _BuildTestSuccessState();
}

class _BuildTestSuccessState extends State<BuildTestSuccess> {
  var redTextStyle = const TextStyle(
      color: Color(0xffFF2F2F), fontWeight: FontWeight.w600, fontSize: 15);
  var greenTextStyle = const TextStyle(
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
                      children: const [
                        Icon(Icons.check_box_rounded),
                        Text(
                            "Part de tests ratées par rapport aux tests réussis"),
                      ]),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: [
                      Text("${((failPourcentage) * 100).round()} %",
                          style: redTextStyle),
                      DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: const [
                                  Color(0xffFF2F2F),
                                  Color(0xffFF2F2F),
                                  Color(0xff00DB09),
                                  Color(0xff00DB09)
                                ],
                                stops: [
                                  0,
                                  failPourcentage,
                                  failPourcentage,
                                  1
                                ]),
                          ),
                          child: const SizedBox(height: 20, width: 320)),
                      Text("${((1 - failPourcentage) * 100).round()} %",
                          style: greenTextStyle)
                    ],
                  )
                ])));
  }
}
