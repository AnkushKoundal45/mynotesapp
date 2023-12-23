import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

// made this class to make sure the user's email is verified
// via the help of a factory constrtuctor which takes user from firebase and give it to the constructor isEmailVerified.
@immutable
class AuthUser {
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified});
  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
      );
}
