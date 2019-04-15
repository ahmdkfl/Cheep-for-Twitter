
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => SettingsState();
    
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(width: double.infinity,
          child: FlatButton(
            child: Text("Logout"),
            onPressed: (){
              _removeCredentials();
            },
          ),
        )
      ],
    );
  }

  Future<bool> _removeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cred = prefs.getString("credentials");
    prefs.remove("credentials");
    return prefs.commit();
  }
  
}