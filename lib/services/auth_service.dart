import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId => _userId;
  String? get email => _email;

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=${FirebaseConfig.apiKey}',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (responseData['error'] != null) {
        throw Exception(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _email = responseData['email'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData['expiresIn'])),
      );
      
      _autoLogout();
      notifyListeners();
      
    } catch (error) {
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _email = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
