import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:core';
import 'package:html/parser.dart' show parse;
import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheep_for_twitter/tweet.dart';
import 'package:cheep_for_twitter/TweetCard.dart';

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
      lauchScreen(MyApp());
    });
}
class MyApp extends StatelessWidget {

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
    client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
      print(res.body);
    });
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
                child: getHomeTimeline2(client)),
              new Container(color: Colors.white, 
                child: getUserProfile2(client)
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

Future<dynamic> getUserInfo(client){
  return client.get('https://api.twitter.com/1.1/account/verify_credentials.json').then((res) {
      return res;
  });
}

Future<dynamic> getUserTimeline(client){
  return client.get('https://api.twitter.com/1.1/statuses/user_timeline.json').then((res) {
      return res;
  });
}

Future<dynamic> getHomeTimelineInfo(client){
  return client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=200').then((res) {
      return res;
  });
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

getHomeTimeline(client){
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
                    future: getHomeTimelineInfo(client),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.done){
                        List<dynamic> userTweets = json.decode(snapshot.data.body);

                        List<Widget> list = new List<Widget>();
                        userTweets.forEach((tweet){
                          Map<String, dynamic> userData = tweet['retweeted_status'];
                          var t = Tweet.fromJson(tweet);

                          var image, name, username, text, retweet, repliesCount, retweetsCount, favoriteCount;
                          if(t.retweet_status == null){
                            text = t.text;
                            image = t.user['profile_image_url'];
                            name = t.user['name'];
                            username = t.user['screen_name'];
                            retweet = "Retweet";
                            repliesCount = tweet['reply_count'];
                            retweetsCount = tweet['retweet_count'];
                            favoriteCount = t.user['favourites_count'];
                          }
                          else {
                            text = t.retweet_status['text'];
                            image = t.retweet_status['user']['profile_image_url'];
                            name = t.retweet_status['user']['name'];
                            username = t.retweet_status['user']['screen_name'];
                            retweet = "";
                          }
                          print(t.retweet_status);

                          list.add(Card(
                            child: Padding(padding: EdgeInsets.all(9),
                              child:Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), child:
                                    ClipOval(
                                      child: Image.network(
                                        image.replaceAll(new RegExp(r'normal'), '200x200'),
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Expanded(child: 
                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(children: <Widget>[
                                        Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text(" @"+username, style: TextStyle(color: Colors.grey),)
                                        ]),
                                        Text(text),
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                                          Row(children: <Widget>[
                                            Icon(Icons.replay, size: 15),
                                            Text(retweetsCount.toString())
                                            ]
                                          ),
                                          Row(children: <Widget>[
                                            Icon(Icons.favorite, size: 15),
                                            Text(favoriteCount.toString()),
                                            ]
                                          ),
                                          Row(children: <Widget>[
                                            Icon(Icons.reply, size: 15),
                                            Text(repliesCount.toString())
                                            ]
                                          ),
                                        ],)
                                      ]
                                    )
                                  )
                                  ]
                                )
                              )
                            )
                          );
                        });
                        return new Column(children: list);
                        }
                      else
                        return Column(children: <Widget>[CircularProgressIndicator()]);
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

getHomeTimeline2(client){

  return Container(
    child: FutureBuilder(
      future: getHomeTimelineInfo(client),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          List<dynamic> userTweets = json.decode(snapshot.data.body);

          List<Widget> list = new List<Widget>();
          userTweets.forEach((tweet){
            Map<String, dynamic> userData = tweet['retweeted_status'];
            var t = Tweet.fromJson(tweet);

            var image, name, username, text, retweet, repliesCount, retweetsCount, favoriteCount;
            if(t.retweet_status == null){
              text = t.text;
              image = t.user['profile_image_url'];
              name = t.user['name'];
              username = t.user['screen_name'];
              retweet = "Retweet";
              repliesCount = tweet['reply_count'];
              retweetsCount = tweet['retweet_count'];
              favoriteCount = t.user['favourites_count'];
            }
            else {
              text = t.retweet_status['text'];
              image = t.retweet_status['user']['profile_image_url'];
              name = t.retweet_status['user']['name'];
              username = t.retweet_status['user']['screen_name'];
              retweet = "";
            }
            print(t.retweet_status);
            
            list.add(TweetCard(username, name, image, text, retweetsCount, favoriteCount, repliesCount));
          });
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: list[index],
              );
            },
          );
          }
        else
          return Column(children: <Widget>[CircularProgressIndicator()]);
      },
    ),
  );
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
                      if(snapshot.connectionState == ConnectionState.done){
                        Map<String, dynamic> data = json.decode(snapshot.data.body);
                        return Container(child:
                          Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Card(child:
                                Padding(padding: EdgeInsets.all(9),child:
                                  Center(
                                    child:Column(children: <Widget>[
                                      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
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
                                        ]
                                      ),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                                        Text(data['followers_count'].toString()+" Followers"),
                                        Text(data['friends_count'].toString()+ " Following")
                                        ]
                                      )
                                      ],)
                                    ),
                                  ),
                                ),
                              ],
                            )
                          );
                        }
                        else
                          return Column(children: <Widget>[CircularProgressIndicator()]);
                    },
                  ),
                ),
                Container(child:
                  FutureBuilder(
                    future: getUserTimeline(client),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.done){
                        List<dynamic> userTweets = json.decode(snapshot.data.body);

                        List<Widget> list = new List<Widget>();
                        userTweets.forEach((tweet){
                          // Map<String, dynamic> userData = tweet['retweeted_status'];
                          var t = Tweet.fromJson(tweet);

                          var image, name, username, text, retweet, repliesCount, retweetsCount, favoriteCount;
                          if(t.retweet_status == null){
                            text = t.text;
                            image = t.user['profile_image_url'];
                            name = t.user['name'];
                            username = t.user['screen_name'];
                            retweet = "Retweet";
                            repliesCount = tweet['reply_count'];
                            retweetsCount = tweet['retweet_count'];
                            favoriteCount = t.user['favourites_count'];
                          }
                          else {
                            text = t.retweet_status['text'];
                            image = t.retweet_status['user']['profile_image_url'];
                            name = t.retweet_status['user']['name'];
                            username = t.retweet_status['user']['screen_name'];
                            retweet = "";
                            repliesCount = tweet['reply_count'];
                            retweetsCount = tweet['retweet_count'];
                            favoriteCount = t.user['favourites_count'];
                          }
                          print(t.retweet_status);

                          list.add(Card(
                            child: Padding(padding: EdgeInsets.all(9),
                              child:Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0), child:
                                    ClipOval(
                                      child: Image.network(
                                        image.replaceAll(new RegExp(r'normal'), '200x200'),
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Expanded(child: 
                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(children: <Widget>[
                                        Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text(" @"+username, style: TextStyle(color: Colors.grey),)
                                        ]),
                                        Text(text),
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                                          Row(children: <Widget>[
                                            Icon(Icons.replay, size: 15),
                                            Text(retweetsCount.toString())
                                            ]
                                          ),
                                          Row(children: <Widget>[
                                            Icon(Icons.favorite, size: 15),
                                            Text(favoriteCount.toString()),
                                            ]
                                          ),
                                          Row(children: <Widget>[
                                            Icon(Icons.reply, size: 15),
                                            Text(repliesCount.toString())
                                            ]
                                          ),
                                        ])
                                      ]
                                    )
                                  )
                                  ]
                                )
                              )
                            )
                          );
                        });
                        return new Column(children: list);
                        }
                      else
                        return Column(children: <Widget>[CircularProgressIndicator()]);
                    },
                  )
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

getUserProfile2(client){
  return ListView(shrinkWrap: true,
    children: <Widget>[
      Container(
        child: FutureBuilder(
          future: getUserInfo(client),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              Map<String, dynamic> data = json.decode(snapshot.data.body);
              return Container(child:
                Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(child:
                      Padding(padding: EdgeInsets.all(9),child:
                        Center(
                          child:Column(children: <Widget>[
                            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
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
                              ]
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                              Text(data['followers_count'].toString()+" Followers"),
                              Text(data['friends_count'].toString()+ " Following")
                              ]
                            )
                            ],)
                          ),
                        ),
                      ),
                    ],
                  )
                );
              }
              else
                return Column(children: <Widget>[CircularProgressIndicator()]);
          },
        ),
      ),
      Container(child:
        FutureBuilder(
          future: getUserTimeline(client),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              List<dynamic> userTweets = json.decode(snapshot.data.body);

              List<Widget> list = new List<Widget>();
              userTweets.forEach((tweet){
                // Map<String, dynamic> userData = tweet['retweeted_status'];
                var t = Tweet.fromJson(tweet);

                var image, name, username, text, retweet, repliesCount, retweetsCount, favoriteCount;
                if(t.retweet_status == null){
                  text = t.text;
                  image = t.user['profile_image_url'];
                  name = t.user['name'];
                  username = t.user['screen_name'];
                  retweet = "Retweet";
                  repliesCount = tweet['reply_count'];
                  retweetsCount = tweet['retweet_count'];
                  favoriteCount = t.user['favourites_count'];
                }
                else {
                  text = t.retweet_status['text'];
                  image = t.retweet_status['user']['profile_image_url'];
                  name = t.retweet_status['user']['name'];
                  username = t.retweet_status['user']['screen_name'];
                  retweet = "";
                  repliesCount = tweet['reply_count'];
                  retweetsCount = tweet['retweet_count'];
                  favoriteCount = t.user['favourites_count'];
                }
                print(t.retweet_status);
            list.add(TweetCard.fromTweet(tweet));
              // list.add(TweetCard(username, name, image, text, retweetsCount, favoriteCount, repliesCount));
              });
              return new Column(children: list);
              }
            else
              return Column(children: <Widget>[CircularProgressIndicator()]);
          },
        )
      )
    ],
  );
}