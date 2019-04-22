import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/pages/user_profile.dart';
import 'package:cheep_for_twitter/pages/profile.dart';
import 'package:cheep_for_twitter/pages/home_timeline.dart';
import 'package:cheep_for_twitter/pages/settings.dart';
import 'package:cheep_for_twitter/pages/new_tweet.dart';

class TabBarHome extends StatefulWidget {
  var tokens;

  TabBarHome(this.tokens);

  @override
  State<StatefulWidget> createState() => _TabBarHomeState();
}

class _TabBarHomeState extends State<TabBarHome>
    with AutomaticKeepAliveClientMixin {
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

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: DefaultTabController(
  //       length: 3,
  //       child: Scaffold(
  //         appBar: AppBar(
  //           title: const Text("Cheep for Twitter"),
  //           centerTitle: true,
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text(
  //                 "Tweet",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () {
  //                 Navigator.push(context, MaterialPageRoute(builder: (_) {
  //                   return NewTweet(client: client);
  //                 }));
  //               },
  //             )
  //           ],
  //         ),
  //         bottomNavigationBar: TabBar(
  //           tabs: [
  //             Tab(icon: Icon(Icons.home)),
  //             Tab(icon: Icon(Icons.perm_identity)),
  //             Tab(icon: Icon(Icons.settings)),
  //           ],
  //           labelColor: Colors.blue,
  //           unselectedLabelColor: Colors.lightBlueAccent,
  //           indicatorSize: TabBarIndicatorSize.label,
  //           indicatorPadding: EdgeInsets.all(5.0),
  //           indicatorColor: Colors.blue,
  //         ),
  //         body: TabBarView(
  //           children: [
  //             new Container(
  //                 color: Colors.white,
  //                 child: HomeTimeline(
  //                   client: client,
  //                 )),
  //             // new Container(
  //             //     color: Colors.white, child: UserProfile(client: client)),
  //             new Container(
  //                 color: Colors.white,
  //                 child: FutureBuilder(
  //                     future: _getUserInfo(client),
  //                     builder: (context, snapshot) {
  //                       if (snapshot.connectionState == ConnectionState.done) {
  //                         Map<String, dynamic> user =
  //                             json.decode(snapshot.data.body);
  //                         return Profile(client: client, user: user);
  //                       }
  //                     })),
  //             new Container(color: Colors.white, child: Settings())
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
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
          body: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    title: Text("Cheep for Twitter"),
                    floating: true,
                    pinned: false,
                    snap: false,
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          "Tweet",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return NewTweet(client: client);
                          }));
                        },
                      )
                    ])
              ];
            },
            body: TabBarView(
              children: [
                new Container(
                    color: Colors.white,
                    child: HomeTimeline(
                      client: client,
                    )),
                // new Container(
                //     color: Colors.white, child: UserProfile(client: client)),
                new Container(
                    color: Colors.white,
                    child: FutureBuilder(
                        future: _getUserInfo(client),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic> user =
                                json.decode(snapshot.data.body);
                            return Profile(client: client, user: user);
                          }
                        })),
                new Container(color: Colors.white, child: Settings())
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<dynamic> _getUserInfo(client) async {
    return await client
        .get('https://api.twitter.com/1.1/account/verify_credentials.json');
  }
}
