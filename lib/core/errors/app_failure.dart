class AppFailure implements Exception {
  AppFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

