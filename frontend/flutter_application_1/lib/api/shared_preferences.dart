import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class SharedApi {

  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences.getInstance();
  }

  static saveProjectInfo(int project_id, String project_owner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('project_id', project_id);
    prefs.setString('project_owner', project_owner);
  }

  // make a function to get both project_id and project_owner from shared preferences
  static Future<int> getProjectId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('project_id') ?? 3;
  }

  static Future<String> getProjectOwner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('project_owner') ?? "damiendesvent";
  }

}

