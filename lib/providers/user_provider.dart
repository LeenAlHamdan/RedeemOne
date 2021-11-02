import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

import '../models/user.dart' as u;

class UserProvider with ChangeNotifier {
  String _userId = '';
  double _userHoures = 0;

  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  u.User _currentUser = u.User(
    id: '',
    fullName: '',
    isAdmin: false,
  );

  final firebaseAuth = FirebaseAuth.instance;

  Timer? _authTimer;

  GoogleSignInAccount? get user => _user;

  String get userId {
    return _userId;
  }

  String get userHoures {
    return _userHoures.toStringAsFixed(3);
  }

  u.User get currentUser1 {
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = u.User(
      id: '',
      fullName: '',
      isAdmin: false,
    );
    _userId = '';
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  bool userIsSignd() {
    return userId != '';
  }

  bool isAdmin() {
    return _currentUser.isAdmin;
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.idToken,
      idToken: googleAuth.idToken,
    );

    final ins = await firebaseAuth.signInWithCredential(credential);
    _userId = ins.user!.uid;

    if (ins.additionalUserInfo!.isNewUser) {
      addUser(u.User(
          fullName: ins.user!.displayName!, id: ins.user!.uid, isAdmin: false));
    } else {
      await findById(_userId);
    }
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'userId': _userId,
    });
    prefs.setString('userData', userData);
    notifyListeners();
  }

  /*Future<void> signInWithGoogle() async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=AIzaSyA5O2r6iaCY3y1nUOuEDm4L-L0WwsarAFU');

    try {
      final response = await http.post(url,
          body: json.encode({
            'requestUri': 'http ://127.0.0.1',
            'postBody': 'google.com',
            'returnSecureToken': true,
            'returnIdpCredential': true,
          }));
      final responseData = json.decode(response.body);
      print('responseData $responseData');

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      /*   _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      ); */
      /* 
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData); */
    } catch (error) {
      print('object error $error');
      rethrow;
    }
  } */

  /* Future<User> findByEmail(String email) async {
//return _categories.firstWhere((category) => category.id == id);
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/users.json?auth=$_token&orderBy="id"&equalTo="$id"');
    try {
      final response = await http.get(url);
      final extractedData =
          json.decode(response.body)[userId] as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        throw HttpException('Can\'t sign in');
      }
      _currentUser = User(
          fullName: extractedData['fullName'],
          id: _userId,
          isAdmin: extractedData['isAdmin']);
      return _currentUser;
    } catch (error) {
      rethrow;
    }
  } */

  Future<void> findById(String id) async {
//return _categories.firstWhere((category) => category.id == id);
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/users.json?orderBy="id"&equalTo="$id"');
    try {
      final response = await http.get(url);
      final extractedData =
          json.decode(response.body)[userId] as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        _userId = '';

        throw HttpException('Can\'t sign in');
      }
      _currentUser = u.User(
          fullName: extractedData['fullName'],
          id: _userId,
          isAdmin: extractedData['isAdmin']);

      notifyListeners();
    } catch (error) {
      _userId = '';
      rethrow;
    }
  }

  Future<void> requestPasswordCode(String email) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyA5O2r6iaCY3y1nUOuEDm4L-L0WwsarAFU');

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'requestType': 'PASSWORD_RESET',
          }));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //    _userId = responseData['localId'];

    } catch (error) {
      rethrow;
    }
  }

  Future<void> _authenticate(String email, String password, String urlSegment,
      [u.User? user]) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA5O2r6iaCY3y1nUOuEDm4L-L0WwsarAFU');

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _userId = responseData['localId'];

      if (urlSegment == 'signUp' && user != null) {
        await addUser(user);
      } else {
        await findById(_userId);
      }
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'userId': _userId,
      });
      prefs.setString('userData', userData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addUser(u.User user) async {
    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/users/$_userId.json');
    try {
      await http.put(
        url,
        body: json.encode({
          'id': _userId,
          'fullName': user.fullName,
          'isAdmin': user.isAdmin,
        }),
      );
      _currentUser = u.User(
        id: _userId,
        fullName: user.fullName,
        isAdmin: user.isAdmin,
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
//    _currentUser = user;
    //  notifyListeners();
  }

  Future<void> signUp(String email, String password, u.User user) async {
    return _authenticate(email, password, 'signUp', user);
  }

  Future<void> setTodayHoures(double val) async {
    final today = (DateFormat('yyyy-MM-dd')).format(DateTime.now());

    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/userhours/$userId/$today.json');

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }

      final data = json.decode(response.body);
      _userHoures = (data == null ? 0 : data ?? 0);

      _userHoures += val;

      notifyListeners();

      await http.put(
        url,
        body: json.encode(
          _userHoures,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getTodayHoures() async {
    final today = (DateFormat('yyyy-MM-dd')).format(DateTime.now());

    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/userhours/$userId/$today.json');
    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }

      final data = json.decode(response.body);
      _userHoures = (data == null ? 0 : data ?? 0);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getHoures(DateTime dateTime1, DateTime dateTime2) async {
    var date1 = (DateFormat('yyyy-MM-dd')).format(dateTime1);
    var date2 = (DateFormat('yyyy-MM-dd')).format(dateTime2);

    final url = Uri.parse(
        'https://redeemone-b36f9-default-rtdb.firebaseio.com/userhours/$userId.json');
    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error heppend!');
      }

      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data != null) {
        double total = 0;

        for (var key in data.keys) {
          if ((key).compareTo(date1) >= 0 && (key).compareTo(date2) <= 0) {
            total += data[key] as double;
          } else if (key.compareTo(date2) > 0) {
            break;
          }
        }
        _userHoures = total;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    _userId = extractedUserData['userId'];

    getTodayHoures();
    await findById(_userId);
    return true;
  }
}
