class QuoteNotFoundException implements Exception {
  final String message;
  final Exception? cause;

  QuoteNotFoundException({
    required this.message,
    this.cause,
  });

  @override
  String toString() {
    return 'QuoteNotFoundException: $message${cause != null ? '\nCaused by: $cause' : ''}';
  }
}
