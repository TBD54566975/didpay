import 'dart:convert';

/// Represents the request body sent to the Deferred Credential endpoint.
///
/// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-9.1)
class DeferredCredentialRequest {
  String transactionId;

  DeferredCredentialRequest({required this.transactionId});

  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

/// Exception thrown when a credential request fails.
class DeferredCredentialRequestException implements Exception {
  final String message;
  final Exception? cause;

  DeferredCredentialRequestException({required this.message, this.cause});

  @override
  String toString() {
    var result = 'DeferredCredentialRequestException: $message';
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}
