import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(MaterialApp(
    title: 'Cheep for Twitter',
    theme: new ThemeData(primaryColor: Colors.blue),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(
        child: RaisedButton(
          child: Text("Login with Twitter"),
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var data = tw();
    // data.then((tweets){
    //   print(tweets);
    // });
    return new MaterialApp(
      routes: {
        "/": (_) => new WebviewScaffold(
              url: "https://www.google.com",
              appBar: new AppBar(
                title: new Text("Widget webview"),
              ),
            ),
      },
    );
  }

  Future<String> tw() async {
    var response;
    Twitter twitter = new Twitter(
        '***REMOVED***',
        '***REMOVED***',
        '***REMOVED***',
        '***REMOVED***');
    try {
      response = await twitter.request("GET", "statuses/user_timeline.json");
    } catch (e) {
      print("Error");
    }
    twitter.close();
    return response.body;
  }
}

void test() async {
// define platform (server)
  var platform = new oauth1.Platform(
      'https://api.twitter.com/oauth/request_token', // temporary credentials request
      'https://api.twitter.com/oauth/authorize', // resource owner authorization
      'https://api.twitter.com/oauth/access_token', // token credentials request
      oauth1.SignatureMethods.HMAC_SHA1 // signature method
      );

// define client credentials (consumer keys)
  const String apiKey = '***REMOVED***';
  const String apiSecret = '***REMOVED***';
  var clientCredentials = new oauth1.ClientCredentials(apiKey, apiSecret);

// create Authorization object with client credentials and platform definition
  var auth = new oauth1.Authorization(clientCredentials, platform);

// request temporary credentials (request tokens)
  var result1 = await auth.requestTemporaryCredentials('oob');
  print(
      "Open with your browser: ${auth.getResourceOwnerAuthorizationURI(result1.credentials.token)}");

// get verifier (PIN)
  stdout.write("PIN: ");
  String verifier = stdin.readLineSync();

// request token credentials (access tokens)
  var result2 =
      await auth.requestTokenCredentials(result1.credentials, verifier);

// yeah, you got token credentials
// create Client object
  var client = new oauth1.Client(
      platform.signatureMethod, clientCredentials, result2.credentials);

// now you can access to protected resources via client
  var result3 = await client
      .get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1');
  print(result3.body);

// NOTE: you can get optional values from AuthorizationResponse object
  print("Your screen name is " + result2.optionalParameters['screen_name']);
}
