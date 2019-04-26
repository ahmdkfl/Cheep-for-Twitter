import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheep_for_twitter/twitterapi.dart';
import 'package:cheep_for_twitter/login_page.dart';
import 'package:cheep_for_twitter/tab_bar_home.dart';

/// Ask the user to login with the Twitter credentials.
class Login extends StatelessWidget {
  Twitterapi twitterApi = new Twitterapi();
  var pinTextFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    pinTextFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a login button for the user to login
    var loginButton = RaisedButton(
      child: Text("Login with Twitter"),
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.blue,
      color: Colors.white,
      onPressed: () {
        twitterApi.getURI().then((res) {
          return twitterApi
              .getAuth()
              .getResourceOwnerAuthorizationURI(res.credentials.token);
        }).then((address) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(address: address),
              ));
        });
      },
    );

    // Create a button which when pressed verifies the login code given from the login page
    var sendPinButton = RaisedButton(
      child: Text("Verify Code"),
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.blue,
      color: Colors.white,
      onPressed: () {
        // Retrieve the code from the text field
        twitterApi.getToken(pinTextFieldController.text).then((res) {
          // Store the credentials on the device
          _setCredentials(res).then((commited) {
            var r = res.credentials.toString();
            var r2 = r.split('=');
            var r3 = r2[1].split('&');
            var oauthTokenSecret = r2[2];
            var oauthToken = r3[0];
            twitterApi.getAuthorClient(oauthToken, oauthTokenSecret);
            // Evoke the homepage screen for the user that logged in
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TabBarHome(),
                ));
          });
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Cheep Login", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        child: ListView(shrinkWrap: false, children: <Widget>[
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Container(
              padding: EdgeInsets.all(50),
              child: Image.asset(
                'assets/twitter.png',
                width: 100,
                height: 100,
              ),
            ),
            // button("Login with Twitter", _lauchLoginPage(context)),
            loginButton,
            Container(
              padding: EdgeInsets.all(50),
              child: Container(
                child:
                    // Text field that asks the user to input the successful login code
                    TextField(
                  decoration: InputDecoration(
                    hintText: 'Please enter PIN',
                  ),
                  controller: pinTextFieldController,
                  maxLength: 7,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Button that verifies the login code
            sendPinButton,
            // button("Verify Code", _verifyCode(context))
          ]),
        ]),
      ),
    );
  }

  Future<bool> _setCredentials(res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var e = res.credentials;
    prefs.setString("credentials", e.toString());
    return prefs.commit();
  }
}
