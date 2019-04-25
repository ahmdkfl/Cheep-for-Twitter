import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tab_bar_home.dart';
import 'package:cheep_for_twitter/login.dart';

Twitterapi twitterApi = new Twitterapi();

void main() async {
  var lauchScreen = (screen) {
    return runApp(
      MaterialApp(
          title: 'Cheep for Twitter',
          theme: new ThemeData(primaryColor: Colors.blue),
          home: screen),
    );
  };

  var credentials = await _getCredentials();
  if (credentials != null)
    lauchScreen(TabBarHome(credentials));
  else
    lauchScreen(Login());
}

Future<String> _getCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String cred = prefs.getString("credentials");
  return cred;
}
