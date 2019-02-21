import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oauth1/oauth1.dart' as oauth1;

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/tweet.dart';
import 'package:cheep_for_twitter/tweet_card.dart';
import 'package:cheep_for_twitter/user_profile.dart';
import 'package:cheep_for_twitter/home_timeline.dart';

Twitterapi api = new Twitterapi();

void main() async {
  var lauchScreen = (screen){ return runApp(MaterialApp(
        title: 'Cheep for Twitter',
        theme: new ThemeData(primaryColor: Colors.blue),
        home: screen
          ),
        );
    };
  
  _getCredentials().then((credentials){
    if(credentials!= null){
      lauchScreen(TabBarHome(keys: credentials));
    }
    else
      lauchScreen(Login());
    });
}
class Login extends StatelessWidget {

  var pinTextFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    pinTextFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var title, returnFunction;
    var button = (title, returnFuction){
      return RaisedButton(
        child: Text(title),
        padding: const EdgeInsets.all(8.0),
        textColor: Colors.blue,
        color: Colors.white,
        onPressed: ()async {
          await returnFunction;           
        },
      );
    };
    var loginButton = RaisedButton(
      child: Text("Login with Twitter"),
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.blue,
      color: Colors.white,
      onPressed: () {
        api.getURI().then((res){
          return api.getAuth().getResourceOwnerAuthorizationURI(res.credentials.token);
        }).then((address){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(address: address),
          ));
        });            
      },
    );
    var sendPinButton = RaisedButton(
      child: Text("Verify Code"),
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.blue,
      color: Colors.white,
      onPressed: (){

        api.getToken(pinTextFieldController.text).then((res){
          _setCredentials(res).then((commited){
          print("Credentials saved");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TabBarHome(keys: res.credentials.toString()),
            ));
          });
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Cheep Login", style: TextStyle(color: Colors.black)), 
        backgroundColor: Colors.white, 
        centerTitle: true,),
      body: Container(
        child: ListView(shrinkWrap: false, 
          children: <Widget>[
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(padding: EdgeInsets.all(50),
                  child:Image.asset(
                    'assets/twitter.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                // button("Login with Twitter", _lauchLoginPage(context)),
                loginButton,
                Container(padding: EdgeInsets.all(50), child:Container(child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Please enter PIN',
                    ),
                    controller: pinTextFieldController,
                    maxLength: 7,
                    textAlign: TextAlign.center,
                  ),
                ),),
                sendPinButton,
                // button("Verify Code", _verifyCode(context))
              ]
            ),
          ]
        ),
      ),
    );
  }

  _lauchLoginPage(context){
    api.getURI().then((res){
      return api.getAuth().getResourceOwnerAuthorizationURI(res.credentials.token);
    }).then((address){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(address: address),
      ));
    });      
  }

  _verifyCode(context){
    api.getToken(pinTextFieldController.text).then((res){
      _setCredentials(res).then((commited){
      print("Credentials saved");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TabBarHome(keys: res.credentials.toString()),
        ));
      });
    });
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
        title: new Text("Cheep Login"),
      ),
    );

    return authorizePage;
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
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(appBar: AppBar(title: const Text("Cheep for Twitter"),centerTitle: true,),
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
              new Container(color: Colors.white,
                child: HomeTimeline(client)),
              new Container(color: Colors.white, 
                child: UserProfile(client)
              ),
              new Container(color: Colors.green)
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _setCredentials(res) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var e = res.credentials;
  prefs.setString("credentials", e.toString());
  return prefs.commit();
}

Future<String> _getCredentials() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	String cred = prefs.getString("credentials");
  return cred;
}

Future<dynamic> getProfileBanner(client){
  return client.get('https://api.twitter.com/1.1/users/profile_banner.json').then((res) {
      return res;
  });
}

returnBanner(client){
  return FutureBuilder(future: getProfileBanner(client),
    builder: (context, snapshot){
      List<dynamic> banners = json.decode(snapshot.data.body);
      print(banners);
      return Image.network(
        null,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        );
    },
  );
}

