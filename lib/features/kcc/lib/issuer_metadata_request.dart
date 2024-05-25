/// Exception thrown when an issuer metadata request fails.
class IssuerMetadataRequestException implements Exception {
  final String message;
  final Exception? cause;

  IssuerMetadataRequestException({required this.message, this.cause});

  @override
  String toString() {
    var result = 'IssuerMetadataRequestException: $message';
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}
