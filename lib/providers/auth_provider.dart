import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isGuest = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null || _isGuest;

  AuthProvider() {
    AuthService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  void continueAsGuest() {
    _isGuest = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isGuest = false;
    await AuthService.signOut();
    // Setting _user to null is handled by the authStateChanges stream
  }
}
