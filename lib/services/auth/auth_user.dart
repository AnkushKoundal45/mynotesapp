import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

// made this class to make sure the user's email is verified
// via the help of a factory constrtuctor which takes user from firebase and give it to the constructor isEmailVerified.
@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified, required this.email});
  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
