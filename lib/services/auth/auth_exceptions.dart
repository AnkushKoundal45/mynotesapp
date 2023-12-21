// login exceptions
class InvalidLoginCredentials implements Exception {}

class InvalidEmailAuthException implements Exception {}

class ChannelErrorAuthException implements Exception {}

// register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
