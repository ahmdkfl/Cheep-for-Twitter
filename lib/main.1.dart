import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    test();
    return MaterialApp(
      title: 'Cheep for Twitter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cheep for Twitter'),
        ),
        body: Center(
          child: Text(''),
        ),
      ),
    );
  }
}
// Twitter twitter= new Twitter('***REMOVED***', '***REMOVED***',
//                   '***REMOVED***', '***REMOVED***');
// var response = twitter.request("GET", "statuses/user_timeline.json");
// print(response);
// twitter.close();

void test() {
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
  auth.requestTemporaryCredentials('oob').then((res) {
    // redirect to authorization page
    print(
        "Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");

    // get verifier (PIN)
    stdout.write("PIN: ");
    String verifier = stdin.readLineSync();

    // request token credentials (access tokens)
    return auth.requestTokenCredentials(res.credentials, verifier);
  }).then((res) {
    // yeah, you got token credentials
    // create Client object
    var client = new oauth1.Client(
        platform.signatureMethod, clientCredentials, res.credentials);

    // now you can access to protected resources via client
    client
        .get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1')
        .then((res) {
      print(res.body);
    });

    // NOTE: you can get optional values from AuthorizationResponse object
    print("Your screen name is " + res.optionalParameters['screen_name']);
  });
}
