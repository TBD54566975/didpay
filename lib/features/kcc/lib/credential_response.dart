import 'dart:convert';

/// Represents the response body received from the PFI's credential endpoint.
///
/// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.3)
class CredentialResponse {
  /// OPTIONAL. Contains issued Credential. It MUST be present when
  /// transaction_id is not returned. It MAY be a string or an object, depending
  ///  on the Credential format. See Appendix A for the Credential format
  /// specific encoding requirements.
  ///
  /// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.3-6.1)
  String? credential;

  /// OPTIONAL. String identifying a Deferred Issuance transaction. This claim
  /// is contained in the response if the Credential Issuer was unable to
  /// immediately issue the Credential. The value is subsequently used to obtain
  /// the respective Credential with the Deferred Credential Endpoint It MUST
  /// be present when the credential parameter is not returned. It MUST be
  /// invalidated after the Credential for which it was meant has been obtained
  /// by the Wallet.
  ///
  /// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.3-6.2)
  String? transactionId;

  CredentialResponse({required this.credential, required this.transactionId});

  factory CredentialResponse.fromJson(String input) {
    return CredentialResponse.fromMap(jsonDecode(input));
  }

  factory CredentialResponse.fromMap(Map<String, dynamic> input) {
    return CredentialResponse(
      credential: input['credential'],
      transactionId: input['transaction_id'],
    );
  }
}

/// Enum representing Credential Error codes as defined in the OpenID Connect for Verifiable Credential Issuance 1.0,
/// Section 7.3.1.
enum CredentialResponseErrorCode {
  /// The request is missing a required parameter, includes an unsupported parameter value,
  /// repeats a parameter, includes multiple credentials, or is otherwise malformed.
  invalidRequest('invalid_request'),

  /// The client is not authorized to request a credential using this method.
  unauthorizedClient('unauthorized_client'),

  /// The resource owner or authorization server denied the request.
  accessDenied('access_denied'),

  /// The requested credential is not available from the authorization server.
  credentialNotAvailable('credential_not_available'),

  /// The requested type is not supported by the authorization server.
  unsupportedCredentialType('unsupported_credential_type');

  /// The machine-readable code of the error as specified in the specification.
  final String code;

  const CredentialResponseErrorCode(this.code);
}

/// Represents error responses returned from credential issuance endpoints
/// as defined in the specification.
class CredentialErrorResponse {
  /// A single ASCII [error] code.
  CredentialResponseErrorCode error;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  String? errorUri;

  CredentialErrorResponse({
    required this.error,
    this.errorDescription,
    this.errorUri,
  });

  factory CredentialErrorResponse.fromJson(String input) {
    return CredentialErrorResponse.fromMap(jsonDecode(input));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates an instance from a map.
  factory CredentialErrorResponse.fromMap(Map<String, dynamic> json) {
    return CredentialErrorResponse(
      error: CredentialResponseErrorCode.values
          .firstWhere((e) => e.code == json['error']),
      errorDescription: json['error_description'],
      errorUri: json['error_uri'],
    );
  }

  /// Converts the [CredentialErrorResponse] to a map.
  Map<String, dynamic> toMap() {
    return {
      'error': error.code,
      if (errorDescription != null) 'error_description': errorDescription,
      if (errorUri != null) 'error_uri': errorUri,
    };
  }
}

/// Custom exception for handling Credential Errors.
class CredentialResponseException implements Exception {
  /// See [CredentialResponseErrorCode]
  final CredentialResponseErrorCode errorCode;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  final String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  final String? errorUri;

  CredentialResponseException({
    required this.errorCode,
    this.errorDescription,
    this.errorUri,
  });

  @override
  String toString() {
    return 'CredentialResponseException: ${errorCode.code} - $errorDescription';
  }

  /// Creates a [CredentialResponseException] from a [CredentialErrorResponse].
  static CredentialResponseException fromErrorResponse(
    CredentialErrorResponse response,
  ) {
    return CredentialResponseException(
      errorCode: response.error,
      errorDescription: response.errorDescription,
      errorUri: response.errorUri,
    );
  }
}

/// Exception thrown when there is an error in processing the credential response.
class CredentialUnknownResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  CredentialUnknownResponseException({
    required this.message,
    required this.status,
    this.body,
    this.cause,
  });

  @override
  String toString() {
    final parts = ['CredentialResponseException: $message', 'Status: $status'];

    if (body != null) {
      parts.add('Response Body: $body');
    }
    if (cause != null) {
      parts.add('Caused by: $cause');
    }
    return parts.join('\n');
  }
}
