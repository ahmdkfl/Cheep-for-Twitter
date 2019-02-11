import 'package:oauth1/oauth1.dart' as oauth1;
import 'dart:async';

class Twitterapi {
  oauth1.Platform platform;
  static const String apiKey = '***REMOVED***';
  static const String apiSecret = '***REMOVED***';
  oauth1.ClientCredentials clientCredentials;
  oauth1.Authorization auth;
  var PIN;
  oauth1.AuthorizationResponse authorizationResult;

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

  Future<dynamic> getURI(){
    return auth.requestTemporaryCredentials('oob').then((res) {
      // redirect to authorization page
      // print("Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");
      // request token credentials (access tokens)
      authorizationResult = res;
      return res;
    });
  }

  getToken(code) {
    return auth.requestTokenCredentials(authorizationResult.credentials, code);
  }

  getAuth(){
    return auth;
  }

  getAuthClient() {
    return new oauth1.Client(platform.signatureMethod, clientCredentials, authorizationResult.credentials);
  }

  getAuthorClient(token, tokenSecret) {
    oauth1.Credentials credentials = new oauth1.Credentials(token, tokenSecret);
    return new oauth1.Client(platform.signatureMethod, clientCredentials, credentials);
  }
}