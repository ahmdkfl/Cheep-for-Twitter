import 'package:oauth1/oauth1.dart' as oauth1;
import 'dart:async';

class Twitterapi {
  var platform;
  static const String apiKey = '***REMOVED***';
  static const String apiSecret =
      '***REMOVED***';
  var clientCredentials;
  var auth;
  var authorizationResult;

  Twitterapi() {
    platform = oauth1.Platform(
        'https://api.twitter.com/oauth/request_token', // temporary credentials request
        'https://api.twitter.com/oauth/authorize', // resource owner authorization
        'https://api.twitter.com/oauth/access_token', // token credentials request
        oauth1.SignatureMethods.HMAC_SHA1 // signature method
        );
    clientCredentials = oauth1.ClientCredentials(apiKey, apiSecret);
    auth = oauth1.Authorization(clientCredentials, platform);
  }

  Future<dynamic> getURI() async {
    var request = await auth.requestTemporaryCredentials('oob');
    authorizationResult = request;
    return request;
  }

  getToken(code) {
    return auth.requestTokenCredentials(authorizationResult.credentials, code);
  }

  getAuth() {
    return auth;
  }

  getAuthClient() {
    return oauth1.Client(platform.signatureMethod, clientCredentials,
        authorizationResult.credentials);
  }

  getAuthorClient(token, tokenSecret) {
    var credentials = oauth1.Credentials(token, tokenSecret);
    return oauth1.Client(
        platform.signatureMethod, clientCredentials, credentials);
  }
}
