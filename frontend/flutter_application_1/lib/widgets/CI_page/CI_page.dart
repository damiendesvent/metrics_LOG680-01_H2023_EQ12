import '../../main.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'build_list.dart';
import 'build_nb.dart';

class CIPageLayout extends StatefulWidget {
  const CIPageLayout({super.key});

  @override
  State<CIPageLayout> createState() => _CIPageLayoutState();
}

class _CIPageLayoutState extends State<CIPageLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(child: BuildList()),
            const SizedBox(width: 30),
            Expanded(child: Column(children: [BuildNb(), SizedBox(height: 30)]))
          ],
        ));
  }
}
