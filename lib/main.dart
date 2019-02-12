import 'package:flutter/material.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'dart:core';
import 'package:html/parser.dart' show parse;
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:shared_preferences/shared_preferences.dart';

Twitterapi api = new Twitterapi();

void main() async {
  getCredentials().then((credentials){
      // var r = credentials; f=fdf&d=fds
      // var r2 = r.split('='); 'f',fdf&d','fds
      // var r3 = r2[1].split('&'); 'fdf', 'd'
      // var oauth_token_sec=r2[2];
      // var oauth_token=r3[0];
    if(credentials!= null){
      var r = credentials;
      var r2 = r.split('=');
      var r3 = r2[1].split('&');
      var oauth_token_sec=r2[2];
      var oauth_token=r3[0];
      print("token: "+oauth_token+"; token_sec: "+oauth_token_sec);
      runApp(MaterialApp(
        title: 'Cheep for Twitter',
        theme: new ThemeData(primaryColor: Colors.blue),
        home: TabBarHome(keys: credentials)
        )
      );
    }
    else
      runApp(MaterialApp(
        title: 'Cheep for Twitter',
        theme: new ThemeData(primaryColor: Colors.blue),
        home: MyApp()
          )
        );
    });
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
    var sendPinButton = RaisedButton(
      child: Text("Send PIN"),
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.white,
      color: Colors.blue,
      onPressed: (){

        api.getToken(pinTFController.text).then((res){
          var client = api.getAuthClient();
          
          setCredentials(res).then((commited){
            print("Credentials saved");

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
        });
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text("Cheep Login")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loginButton,
            Container(child:TextField(
              decoration: InputDecoration(
                hintText: 'Please enter PIN'
              ),
              controller: pinTFController,
              ),
              margin: EdgeInsets.fromLTRB(40, 20, 0, 40),
            ),
            sendPinButton
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

class TabBarHome extends StatelessWidget {

  String keys;

  TabBarHome({Key key, @required this.keys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var r = keys;
    var r2 = r.split('=');
    var r3 = r2[1].split('&');
    var oauth_token_sec=r2[2];
    var oauth_token=r3[0];
    oauth1.Client client = api.getAuthorClient(oauth_token, oauth_token_sec);
    client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
      print(res.body);
    });
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.perm_identity)),
                Tab(icon: Icon(Icons.settings)),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.lightBlueAccent,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.all(5.0),
              indicatorColor: Colors.blue,
            ),
          body: TabBarView(
            children: [
              new Container(color: Colors.green),
              new Container(color: Colors.white, 
                child: getUserProfile(client)
              ),
              new Container(color: Colors.green)
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> setCredentials(res) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var e = res.credentials;
  prefs.setString("credentials", e.toString());
  return prefs.commit();
}

Future<String> getCredentials() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	String cred = prefs.getString("credentials");
  return cred;
}

Future<bool> setCredentials2() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  oauth1.Credentials e = api.authorizationResult.credentials;
  prefs.setString("credentials", e.toJSON().toString());
  return prefs.commit();
}

Future<oauth1.Credentials> getCredentials2() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	String cred = prefs.getString("credentials");
  oauth1.Credentials  e = new oauth1.Credentials.fromJSON(cred);
  return e;
}

Future<dynamic> getUserInfo(client){
  return client.get('https://api.twitter.com/1.1/account/verify_credentials.json').then((res) {
      return res;
  });
}

Future<dynamic> getUserTimeline(client){
  return client.get('https://api.twitter.com/1.1/statuses/home_timeline.json').then((res) {
      return res;
  });
}

// Second Tab for the user profile
getUserProfile(client){
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                Container(
                  child: FutureBuilder(
                    future: getUserInfo(client),
                    builder: (context, snapshot){
                      Map<String, dynamic> data = json.decode(snapshot.data.body);
                      
                      return Container(child:
                        Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Card(child:
                              Padding(padding: EdgeInsets.all(9),child:
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ClipOval(
                                      child: Image.network(
                                          data['profile_image_url'].replaceAll(new RegExp(r'normal'), '200x200'),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Text("@"+data['screen_name']),
                                    Text(data['name'], style: new TextStyle(fontWeight: FontWeight.bold)),
                                    Text(data['followers_count'].toString()+" Followers"),
                                    Text(data['friends_count'].toString()+ " Following")
                                    ]
                                  ),
                                ),
                              ),
                            ],
                          )
                        );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}