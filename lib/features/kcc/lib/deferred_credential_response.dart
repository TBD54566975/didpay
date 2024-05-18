import 'dart:convert';

/// Enum representing Deferred Credential error response codes
///
/// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-9.3)
enum DeferredCredentialResponseErrorCode {
  /// The Credential issuance is still pending. The error response SHOULD also
  /// contain the interval member, determining the minimum amount of time in
  /// seconds that the Wallet needs to wait before providing a new request to
  /// the Deferred Credential Endpoint. If interval member is not present,
  /// the Wallet MUST use 5 as the default value.
  ///
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-9.3-3.1)
  issuancePending('issuance_pending'),

  /// The Deferred Credential Request contains an invalid transaction_id.
  /// This error occurs when the transaction_id was not issued by the
  /// respective Credential Issuer or it was already used to obtain a Credential.
  ///
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-9.3-3.2)
  invalidTransactionId('invalid_transaction_id');

  /// The machine-readable code of the error as specified in the specification.
  final String code;

  const DeferredCredentialResponseErrorCode(this.code);
}

/// Represents error responses returned from credential issuance endpoints
/// as defined in the specification.
class DeferredCredentialErrorResponse {
  /// A single ASCII [error] code.
  DeferredCredentialResponseErrorCode error;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  String? errorUri;

  DeferredCredentialErrorResponse({
    required this.error,
    this.errorDescription,
    this.errorUri,
  });

  factory DeferredCredentialErrorResponse.fromJson(String input) {
    return DeferredCredentialErrorResponse.fromMap(jsonDecode(input));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates an instance from a map.
  factory DeferredCredentialErrorResponse.fromMap(Map<String, dynamic> json) {
    return DeferredCredentialErrorResponse(
      error: DeferredCredentialResponseErrorCode.values
          .firstWhere((e) => e.code == json['error']),
      errorDescription: json['error_description'],
      errorUri: json['error_uri'],
    );
  }

  /// Converts the [DeferredCredentialErrorResponse] to a map.
  Map<String, dynamic> toMap() {
    return {
      'error': error.code,
      if (errorDescription != null) 'error_description': errorDescription,
      if (errorUri != null) 'error_uri': errorUri,
    };
  }
}

/// Custom exception for handling Credential Errors.
class DeferredCredentialResponseException implements Exception {
  /// See [DeferredCredentialResponseErrorCode]
  final DeferredCredentialResponseErrorCode errorCode;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  final String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  final String? errorUri;

  DeferredCredentialResponseException({
    required this.errorCode,
    this.errorDescription,
    this.errorUri,
  });

  @override
  String toString() {
    return 'DeferredCredentialResponseException: ${errorCode.code} - $errorDescription';
  }

  /// Creates a [DeferredCredentialResponseException] from a
  /// [DeferredCredentialErrorResponse].
  static DeferredCredentialResponseException fromErrorResponse(
    DeferredCredentialErrorResponse response,
  ) {
    return DeferredCredentialResponseException(
      errorCode: response.error,
      errorDescription: response.errorDescription,
      errorUri: response.errorUri,
    );
  }
}

/// Exception thrown when there is an error in processing the deferred credential
/// response.
class DeferredCredentialUnknownResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  DeferredCredentialUnknownResponseException({
    required this.message,
    required this.status,
    this.body,
    this.cause,
  });

  @override
  String toString() {
    final parts = [
      'DeferredCredentialResponseException: $message',
      'Status: $status',
    ];

    if (body != null) {
      parts.add('Response Body: $body');
    }
    if (cause != null) {
      parts.add('Caused by: $cause');
    }
    return parts.join('\n');
  }
}
