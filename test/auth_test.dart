import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider._isInitialized, false);
    });
    test('Cannot logout if not intialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedAuthException>()));
    });
    test('Should be able to initialized', () async {
      await provider.intialize();
      expect(provider.isInitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test('Should be able to initialized in less than 3 sec', () async {
      await provider.intialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 3)));
    test('Create user should delegate/represent login user', () async {
      await provider.intialize();
      final badEmail =
          provider.createUser(email: 'foobar@gmail.com', password: 'anything');
      expect(badEmail, throwsA(const TypeMatcher<InvalidEmailAuthException>()));
      final badPassword =
          provider.createUser(email: 'anything', password: 'foobar');
      expect(
          badPassword, throwsA(const TypeMatcher<InvalidLoginCredentials>()));
      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('Logged in user should be able to get email verified', () async {
      await provider.intialize();
      await provider.logIn(email: 'email', password: 'password');
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('Should be able to login and logout', () async {
      await provider.intialize();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      await provider.logOut();
      final user = provider.currentUser;
      expect(user, isNull);
    });
  });
}

class NotInitializedAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedAuthException();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      return await logIn(
        email: email,
        password: password,
      );
    }
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> intialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (email == 'foobar@gmail.com') throw InvalidEmailAuthException();
    if (password == 'foobar') throw InvalidLoginCredentials();
    await Future.delayed(const Duration(seconds: 2));
    const user = AuthUser(
      id: 'my_note',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(_user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (_user == null) throw UserNotLoggedInAuthException();
    const newuser = AuthUser(
      id: 'my_note',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newuser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }
}
