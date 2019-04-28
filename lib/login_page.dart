import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/// Twitter authorization page
class LoginPage extends StatelessWidget {
  // address of the twitter authorization page
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
