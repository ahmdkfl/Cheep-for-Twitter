import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheep_for_twitter/login.dart';

/// Setting page
/// Contains the logout button
class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          // Logout button
          child: FlatButton(
            child: Text("Logout"),
            onPressed: () {
              // When pressed
              // delete the credentials from the device
              _removeCredentials();
              // Replace the current screen with the Login screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ));
            },
          ),
        )
      ],
    );
  }

  /// Removes credentials from the device
  Future<bool> _removeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cred = prefs.getString("credentials");
    prefs.remove("credentials");
    return prefs.commit();
  }
}
