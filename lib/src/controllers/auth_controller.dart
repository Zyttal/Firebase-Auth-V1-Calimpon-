import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:state_change_demo/src/enum/enum.dart';

class AuthController with ChangeNotifier {
  // Static method to initialize the singleton in GetIt
  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  // Static getter to access the instance through GetIt
  static AuthController get instance => GetIt.instance<AuthController>();

  static AuthController get I => GetIt.instance<AuthController>();

  late StreamSubscription<User?> currentAuthedUser;

  listen() {
    currentAuthedUser =
        FirebaseAuth.instance.authStateChanges().listen(handleUserChanges);
  }

  void handleUserChanges(User? user) {
    if (user == null) {
      state = AuthState.unauthenticated;
    } else {
      state = AuthState.authenticated;
    }
    notifyListeners();
  }

  AuthState state = AuthState.unauthenticated;
  // SimulatedAPI api = SimulatedAPI();
  FirebaseAuth _auth = FirebaseAuth.instance;

  login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      currentAuthedUser = _auth.authStateChanges().listen(handleUserChanges);

      notifyListeners();
    } catch (e) {
      print("Failed to login: $e");
    }
  }

  register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      currentAuthedUser = _auth.authStateChanges().listen(handleUserChanges);
      notifyListeners();
    } catch (e) {
      print("Failed to Register: $e");
    }
  }

  ///write code to log out the user and add it to the home page.
  logout() async {
    await _auth.signOut();
    state = AuthState.unauthenticated;
    notifyListeners();
  }

  ///must be called in main before runApp
  ///
  loadSession() async {
    //check secure storage method
  }

  ///https://pub.dev/packages/flutter_secure_storage or any caching dependency of your choice like localstorage, hive, or a db
}

class SimulatedAPI {
  Map<String, String> users = {"testUser": "12345678ABCabc!"};

  Future<bool> login(String userName, String password) async {
    await Future.delayed(const Duration(seconds: 4));
    if (users[userName] == null) throw Exception("User does not exist");
    if (users[userName] != password)
      throw Exception("Password does not match!");
    return users[userName] == password;
  }
}
