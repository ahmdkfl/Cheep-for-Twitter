import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/pages/user_profile.dart';
import 'package:cheep_for_twitter/pages/home_timeline.dart';
import 'package:cheep_for_twitter/pages/settings.dart';
import 'package:cheep_for_twitter/pages/new_tweet.dart';

class TabBarHome extends StatefulWidget {
  var tokens;

  TabBarHome(this.tokens);

  @override
  State<StatefulWidget> createState() => _TabBarHomeState();
}

class _TabBarHomeState extends State<TabBarHome> {
  var client, api = Twitterapi();

  @override
  void initState() {
    var r = widget.tokens;
    var r2 = r.split('=');
    var r3 = r2[1].split('&');
    var oauth_token_sec = r2[2];
    var oauth_token = r3[0];
    client = api.getAuthorClient(oauth_token, oauth_token_sec);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Cheep for Twitter"),
            centerTitle: true,
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Tweet",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return NewTweet(client: client);
                  }));
                },
              )
            ],
          ),
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
              new Container(
                  color: Colors.white,
                  child: HomeTimeline(
                    client: client,
                  )),
              new Container(
                  color: Colors.white, child: UserProfile(client: client)),
              new Container(color: Colors.white, child: Settings())
            ],
          ),
        ),
      ),
    );
  }
}
