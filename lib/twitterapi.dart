import 'package:oauth1/oauth1.dart' as oauth1;
import 'dart:async';

class Twitterapi {
  var platform;
  static const String apiKey = '***REMOVED***';
  static const String apiSecret = '***REMOVED***';
  var clientCredentials;
  var auth;
  var PIN;
  var authorizationResult;

  Twitterapi(){
    platform = new oauth1.Platform(
      'https://api.twitter.com/oauth/request_token', // temporary credentials request
      'https://api.twitter.com/oauth/authorize',     // resource owner authorization
      'https://api.twitter.com/oauth/access_token',  // token credentials request
      oauth1.SignatureMethods.HMAC_SHA1              // signature method
    );
    clientCredentials = new oauth1.ClientCredentials(apiKey, apiSecret);
    auth = new oauth1.Authorization(clientCredentials, platform);
  }

  getAuthorizationURL() {
    // var result1 = await auth.requestTemporaryCredentials('oob');
    // return auth.getResourceOwnerAuthorizationURI(result1.credentials.token);
    return auth.requestTemporaryCredentials('oob');
  }

  verifyPIN(result) {
    // var result2 = await auth.requestTokenCredentials(result1.credentials, verifier);
    auth.requestTokenCredentials(result.credentials, getPIN()).then((res){
      // yeah, you got token credentials
      // create Client object
      var client = new oauth1.Client(platform.signatureMethod, clientCredentials, res.credentials);

      // now you can access to protected resources via client
      client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
        print(res.body);
        
      });

    });
  }

  Future<dynamic> getURI(){
    return auth.requestTemporaryCredentials('oob').then((res) {
      // redirect to authorization page
      // print("Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");
      // request token credentials (access tokens)
      authorizationResult = res;
      return res;
    });
  }

  getURII(res) async {
    return await auth.getResourceOwnerAuthorizationURI(res.credentials.token);
  }

  getToken(code) async {
    return await auth.requestTokenCredentials(authorizationResult.credentials, code);
  }

  setPIN(pin){
    PIN = pin;
  }
  
  String getPIN(){
    return PIN;
  }

  getAuth(){
    return auth;
  }

  getAuthClient() {
    return new oauth1.Client(platform.signatureMethod, clientCredentials, authorizationResult.credentials);
  }
}