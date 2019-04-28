import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tab_bar_home.dart';
import 'package:cheep_for_twitter/login.dart';

// Create a twitter api instance
Twitterapi twitterApi = new Twitterapi();

void main() async {
  // variable that acts a function that takes screen as a parameter
  var lauchScreen = (screen) {
    return runApp(
      MaterialApp(
          // Title of the app
          title: 'Cheep for Twitter',
          theme: new ThemeData(primaryColor: Colors.blue),
          home: screen),
    );
  };

  // Get the credentials saved from the device
  var credentials = await _getCredentials();

  // if the credentials does exist
  if (credentials != null) {
    var r = credentials;
    var r2 = r.split('=');
    var r3 = r2[1].split('&');
    var oauthTokenSecret = r2[2];
    var oauthToken = r3[0];
    // Pass the credentials to the Twitterapi
    // so it can create a client
    twitterApi.getAuthorClient(oauthToken, oauthTokenSecret);
    // launches the TabBarHome screen
    lauchScreen(TabBarHome());
  } else
    // if the credentials does not exist then it open the Login page
    lauchScreen(Login());
}

Future<String> _getCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String cred = prefs.getString("credentials");
  return cred;
}
