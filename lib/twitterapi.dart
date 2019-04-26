import 'package:oauth1/oauth1.dart' as oauth1;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Contains the platform, clientCredentials, auth, apiKey and apiSecret
///
/// This class utilises the oauth1 plugin. The platform requests from the Twitter API the requestes the are needed.
/// The clientCredentials class contains the apiKey and the apiSecret. Both classes make up an authorization request.
class Twitterapi {
  static const String _apiKey = '***REMOVED***';
  static const String _apiSecret =
      '***REMOVED***';
  static var _platform, _clientCredentials, _auth, _authorizationResult, client;

  /// Create instances of platform, client credentials and authorization
  static final Twitterapi _client = new Twitterapi._internal();

  factory Twitterapi() {
    return _client;
  }

  Twitterapi._internal(){
    _platform = oauth1.Platform(
        'https://api.twitter.com/oauth/request_token', // temporary credentials request
        'https://api.twitter.com/oauth/authorize', // resource owner authorization
        'https://api.twitter.com/oauth/access_token', // token credentials request
        oauth1.SignatureMethods.hmacSha1 // signature method
        );
    _clientCredentials = oauth1.ClientCredentials(_apiKey, _apiSecret);
    _auth = oauth1.Authorization(_clientCredentials, _platform);
  }

  /// Returns the URL to sign in for the user credentials
  ///
  /// The URL is returned as a Future from an asyncronous operation and the value returned is a String when
  /// the Future is processed
  Future<dynamic> getURI() async {
    var request = await _auth.requestTemporaryCredentials('oob');
    _authorizationResult = request;
    return request;
  }

  /// Verifies the PIN and returns token and secret_token
  getToken(code) {
    return _auth.requestTokenCredentials(
        _authorizationResult.credentials, code);
  }

  /// Return the current authorization request
  getAuth() {
    return _auth;
  }

  getClient(){
    return client;
  }

  /// Not needed
  getAuthClient() {
    print(_authorizationResult);
    return oauth1.Client(_platform.signatureMethod, _clientCredentials,
        _authorizationResult.credentials);
  }

  /// Return a client instance given a token and a secret token
  getAuthorClient(token, tokenSecret) {
    var credentials = oauth1.Credentials(token, tokenSecret);
    client = oauth1.Client(
        _platform.signatureMethod, _clientCredentials, credentials);
        return client;
  }

  static Future<String> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cred = prefs.getString("credentials");
    return cred;
  }
}
