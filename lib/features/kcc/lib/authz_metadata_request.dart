/// Exception thrown when an authorization metadata request fails.
class AuthorizationMetadataRequestException implements Exception {
  final String message;
  final Exception? cause;

  AuthorizationMetadataRequestException({required this.message, this.cause});

  @override
  String toString() {
    var result = 'AuthorizationMetadataRequestException: $message';
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}
