import 'package:flutter_test/flutter_test.dart';

import '../lib/services/auth_controller.dart';

void main() {
  test('starts in loading state without auto initialization', () {
    final auth = AuthController(autoInitialize: false);
    expect(auth.status, AuthStatus.loading);
    expect(auth.isAuthenticated, isFalse);
  });

  test('test session enters the protected dashboard state', () {
    final auth = AuthController.testAuthenticated(email: 'operator@example.com');
    expect(auth.status, AuthStatus.authenticated);
    expect(auth.email, 'operator@example.com');
    expect(auth.name, 'BMS Operator');
  });
}
