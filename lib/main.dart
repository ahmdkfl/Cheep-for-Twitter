import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheep_for_twitter/twitterapi.dart';

Twitterapi api = new Twitterapi();

void main() async {
  runApp(MaterialApp(
    title: 'Cheep for Twitter',
    theme: new ThemeData(primaryColor: Colors.blue),
    home: MyApp()
    )
  );
}
class MyApp extends StatelessWidget {

  String address;
  var pinTFController = TextEditingController();


  MyApp({Key key, @required this.address}) : super(key: key);

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    pinTFController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var loginButton = RaisedButton(
          child: Text("Login with Twitter"),
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {

            api.getURI().then((res){
              return api.getAuth().getResourceOwnerAuthorizationURI(res.credentials.token);
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
                        controller: pinTFController,
                      ),margin: EdgeInsets.fromLTRB(40, 20, 0, 40),),
                      RaisedButton(
                        child: Text("Send PIN"),
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: (){

                          api.getToken(pinTFController.text).then((res){
                            var client = api.getAuthClient();

                            // now you can access to protected resources via client
                            client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
                              print(res.body);
                              
                            });

                            // NOTE: you can get optional values from AuthorizationResponse object
                            print("Your screen name is " + res.optionalParameters['screen_name']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login(pin: res.optionalParameters['screen_name']),
                            ));
                          });
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
    
    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(child: Text(pin),
      ),
    );
  }
}

class Test extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(child: Text(""),
      ),
    );
  }
}