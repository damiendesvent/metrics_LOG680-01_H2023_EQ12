import 'dart:async';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'dart:io';

class Api {
  static const int TIMEOUT_TIME = 5;

  //Gets mind structure
  Future<String> getCardsByColumnAndTimeRange(String columnName, DateTimeRange timeRange) async {
    try {

      var start_date = timeRange.start.toIso8601String();
      var end_date = timeRange.end.toIso8601String();

      // columm_name might have emojis, so we need to encode it
      var encodedColumnName = Uri.encodeComponent(columnName);

      // We need to encode the date range as well
      var encodedStart = Uri.encodeComponent(start_date);
      var encodedEnd = Uri.encodeComponent(end_date);

      //http://127.0.0.1:5000/api/get_column_cards_by_time_range/Done%E2%9C%85?start_date=2023-02-03T23%3A57%3A35.154Z&end_date=2023-02-03T23%3A57%3A35.154Z&page_number=1&items_count=20

      var finalUrl = "http://127.0.0.1:5000/api/get_column_cards_by_time_range/$encodedColumnName?start_date=$start_date&end_date=$end_date&page_number=1&items_count=20";
      var url = Uri.parse(finalUrl);

      // add start_date and end_date to url query parameters
      var headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };

      var response = await http.get(url, headers: headers).timeout(const Duration(seconds: TIMEOUT_TIME));

      print("Final getCurrentUser: $url");
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Response: " + response.body);
        return response.body;
      } else {
        return Future.error("Is server running?");
      }
    }
    on TimeoutException catch (_) {
      return Future.error("Is server running?");
    }
    on SocketException catch (_) {
      return Future.error("Is your internet connection working?");
    }
  }


}