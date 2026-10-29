import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { loading, signedOut, needsVerification, authenticated, error }

class AuthController extends ChangeNotifier {
  AuthController({this.autoInitialize = true}) {
    if (autoInitialize) initialize();
  }

  final bool autoInitialize;
  AuthStatus _status = AuthStatus.loading;
  String? _email;
  String? _name;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  String? get email => _email;
  String? get name => _name;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get needsVerification => _status == AuthStatus.needsVerification;
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _status = AuthStatus.signedOut;
      } else {
        await _applyUser(user);
      }
    } catch (error) {
      _setError(error);
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _run(() async {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await _applyUser(user);
    });
  }

  Future<void> createAccount(String email, String password) async {
    await _run(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await user.sendEmailVerification();
      _email = user.email;
      _name = user.displayName;
      _status = AuthStatus.needsVerification;
    });
  }

  Future<void> signInWithGoogle() async {
    await _run(() async {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      final credential = await _firebaseAuth.signInWithPopup(provider);
      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await _applyUser(user);
    });
  }

  Future<void> resendVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _run(() async {
      await user.sendEmailVerification();
      _errorMessage = 'Verification email sent. Check your inbox.';
      _status = AuthStatus.needsVerification;
    });
  }

  Future<void> refreshVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return initialize();
    await _run(() async {
      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed != null) await _applyUser(refreshed);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _run(() async {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      _errorMessage = 'Password reset email sent. Check your inbox.';
      _status = AuthStatus.signedOut;
    });
  }

  Future<void> logout() async {
    _busy = true;
    notifyListeners();
    try {
      await _firebaseAuth.signOut();
    } finally {
      _email = null;
      _name = null;
      _errorMessage = null;
      _busy = false;
      _status = AuthStatus.signedOut;
      notifyListeners();
    }
  }

  static AuthController testAuthenticated({String email = 'operator@bms.test'}) {
    final controller = AuthController(autoInitialize: false);
    controller._email = email;
    controller._name = 'BMS Operator';
    controller._status = AuthStatus.authenticated;
    return controller;
  }

  Future<void> _run(Future<void> Function() operation) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
    } catch (error) {
      _setError(error);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _applyUser(User user) async {
    _email = user.email;
    _name = user.displayName ?? user.email?.split('@').first;
    final usesEmailPassword = user.providerData.any((provider) => provider.providerId == 'password');
    if (usesEmailPassword && !user.emailVerified) {
      _status = AuthStatus.needsVerification;
    } else {
      _status = AuthStatus.authenticated;
    }
  }

  void _setError(Object error) {
    final code = error is FirebaseAuthException ? error.code : '';
    _status = AuthStatus.error;
    _errorMessage = switch (code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Use a stronger password with at least 6 characters.',
      'invalid-email' => 'Enter a valid email address.',
      'popup-closed-by-user' => 'Google sign-in was cancelled.',
      'popup-blocked' => 'Your browser blocked the Google sign-in popup.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      _ => kDebugMode ? 'Authentication error: ${error.toString()}' : 'Authentication failed. Please try again.',
    };
  }
}
