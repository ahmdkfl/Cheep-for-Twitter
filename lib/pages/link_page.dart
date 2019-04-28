import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// Twitter authorization page
class LinkPage extends StatelessWidget {
  // Address of the authorization page
  final String address;

  LinkPage({Key key, @required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The plugin flutter_webview_plugin is used here
    var authorizePage = new WebviewScaffold(
      url: address,
      appBar: new AppBar(
        // Screen title
        title: new Text("Cheep Login"),
      ),
    );

    return authorizePage;
  }
}
