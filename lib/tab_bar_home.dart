import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/pages/user_profile.dart';
import 'package:cheep_for_twitter/pages/home_timeline.dart';

class TabBarHome extends StatefulWidget {

  var _keys;

  TabBarHome(keys){
    this._keys = keys;
  }

  @override
  State<StatefulWidget> createState() => _TabBarHomeState(_keys);
}

class _TabBarHomeState extends State<TabBarHome> {

  String keys;
  var client, api = Twitterapi();

  _TabBarHomeState(keys){
    this.keys = keys;
  }

  @override
  void initState(){
    var r = keys;
    var r2 = r.split('=');
    var r3 = r2[1].split('&');
    var oauth_token_sec=r2[2];
    var oauth_token=r3[0];
    client = api.getAuthorClient(oauth_token, oauth_token_sec);
  }

  @override
  Widget build(BuildContext context) {
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