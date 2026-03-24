class AuthFailure implements Exception {
  AuthFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthFailure(code: $code, message: $message)';
}


