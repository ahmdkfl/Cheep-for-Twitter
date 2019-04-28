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
  if (credentials != null) {
  var r = credentials;
  var r2 = r.split('=');
  var r3 = r2[1].split('&');
  var oauthTokenSecret = r2[2];
  var oauthToken = r3[0];
  twitterApi.getAuthorClient(oauthToken, oauthTokenSecret);
  if (credentials != null)
    lauchScreen(TabBarHome());
  } else
    lauchScreen(Login());
}

Future<String> _getCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String cred = prefs.getString("credentials");
  return cred;
}
