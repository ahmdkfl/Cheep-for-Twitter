import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

// define platform (server)
var platform = new oauth1.Platform(
    'https://api.twitter.com/oauth/request_token', // temporary credentials request
    'https://api.twitter.com/oauth/authorize',     // resource owner authorization
    'https://api.twitter.com/oauth/access_token',  // token credentials request
    oauth1.SignatureMethods.HMAC_SHA1              // signature method
    );

// define client credentials (consumer keys)
const String apiKey = '***REMOVED***';
const String apiSecret = '***REMOVED***';
var clientCredentials = new oauth1.ClientCredentials(apiKey, apiSecret);

// create Authorization object with client credentials and platform definition
var auth = new oauth1.Authorization(clientCredentials, platform);

var result;

void main() {
  runApp(MaterialApp(
    title: 'Cheep for Twitter',
    theme: new ThemeData(primaryColor: Colors.blue),
    home: MyApp(),
  ));
}
class MyApp extends StatelessWidget {

  String address;
  var myController = TextEditingController();


  MyApp({Key key, @required this.address}) : super(key: key);

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var loginButton = RaisedButton(
          child: Text("Login with Twitter"),
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            // request temporary credentials (request tokens)
            auth.requestTemporaryCredentials('oob').then((res) {
              // redirect to authorization page
              print("Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");
              // get verifier (PIN)
              stdout.write("PIN: ");
              String verifier = stdin.readLineSync();
              result = res;
              // request token credentials (access tokens)
              return auth.getResourceOwnerAuthorizationURI(res.credentials.token);
            }).then((res){
              print("Result"+res);
              address = res;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(address: address),
              ));
            });
            
          },
        );

    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [loginButton,
                      Container(child:TextField(
                        decoration: InputDecoration(
                          hintText: 'Please enter a search term'
                        ),
                        controller: myController,
                      ),margin: EdgeInsets.fromLTRB(40, 20, 0, 40),),
                      RaisedButton(
                        child: Text("Send PIN"),
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login(pin: myController.text),
                            ));
                        },
                        )
                      ]
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {

  final String address;

  LoginPage({Key key, @required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var authorizePage = new WebviewScaffold(
                  url: address,
                  appBar: new AppBar(
                    title: new Text("Widget webview"),
                  ),
                );

    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(child: new MaterialApp(
              routes: {
                "/": (_) => authorizePage
              }
            ),
      ),
    );
  }
}

class Login extends StatelessWidget {

  final String pin;

  Login({Key key, @required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var results;

    auth.requestTokenCredentials(result.credentials, pin).then((res){
      // yeah, you got token credentials
      // create Client object
      var client = new oauth1.Client(platform.signatureMethod, clientCredentials, res.credentials);

      // now you can access to protected resources via client
      client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
        print(res.body);
        results = res.body;
      });

      // NOTE: you can get optional values from AuthorizationResponse object
      print("Your screen name is " + res.optionalParameters['screen_name']);
    });
    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(child: Text(results),
      ),
    );
  }
}