import 'dart:convert';

/// Represents a successful response to an access token request as described
/// in [RFC 6749 Section 5.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1).
/// This includes fields specific to the OID4VCI per [Section 6.2](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.2)
class TokenResponse {
  /// The access token issued by the authorization server
  String accessToken;

  /// The type of the token issued as described in [Section 7.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-7.1).
  /// Value is case insensitive. Expected to be `bearer per [RFC 6750](https://www.rfc-editor.org/rfc/rfc6750)
  String tokenType;

  int expiresIn;

  /// String containing a nonce to be used when creating a proof of possession
  /// of the key proof (see Section 7.2). When received, the Wallet MUST use
  /// this nonce value for its subsequent requests until the Credential Issuer
  /// provides a fresh nonce.
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.2-4.1)
  String cNonce;

  /// Number denoting the lifetime in seconds of the c_nonce
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.2-4.2)
  int cNonceExpiresIn;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.cNonce,
    required this.cNonceExpiresIn,
  });

  factory TokenResponse.fromJson(String input) {
    final data = jsonDecode(input);
    return TokenResponse.fromMap(data);
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory TokenResponse.fromMap(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      cNonce: json['c_nonce'] as String,
      cNonceExpiresIn: json['c_nonce_expires_in'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'c_nonce': cNonce,
      'c_nonce_expires_in': cNonceExpiresIn,
    };
  }
}

/// Enum representing OAuth 2.0 error codes as defined in [RFC 6749 Section 5.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
/// In addition to the error codes added in the [OID4VC spec](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.3).
enum TokenResponseErrorCode {
  /// Occurs if
  /// * The Authorization Server does not expect a Transaction Code in the
  ///   Pre-Authorized Code Flow but the Client provides a Transaction Code.
  /// * The Authorization Server expects a Transaction Code in the
  ///   Pre-Authorized Code Flow but the Client does not provide a
  ///   Transaction Code.
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.3-3)
  invalidRequest('invalid_request'),

  /// The client is not authorized to request an authorization
  /// code using this method.
  ///
  /// [Reference](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
  unauthorizedClient('unauthorized_client'),

  /// The Client tried to send a Token Request with a Pre-Authorized Code
  /// without a Client ID but the Authorization Server does not support
  /// anonymous access.
  ///
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.3-7)
  invalidClient('invalid_client'),

  /// The authorization grant type is not supported by the authorization server
  ///
  /// [Reference](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
  unsupportedGrantType('unsupported_grant_type'),

  /// The requested scope is invalid, unknown, or malformed.
  ///
  /// [Reference](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
  invalidScope('invalid_scope'),

  /// This error code is used if the Authorization Server is waiting for an
  /// End-User interaction or a downstream process to complete. The Wallet
  /// SHOULD repeat the access token request to the token endpoint
  /// (a process known as polling). Before each new request, the Wallet MUST
  /// wait at least the number of seconds specified by the interval claim
  /// of the Credential Offer (see Section 4.1.1) or the authorization response
  /// (see Section 5.2), or 5 seconds if none was provided, and respect any
  /// increase in the polling interval required by the "slow_down" error.
  /// The Wallet MUST repeat the request until it receives a response with
  /// a status code other than 202 (Accepted) or until the Wallet receives
  /// an error response that is not "authorization_pending".
  authorizationPending('authorization_pending'),

  /// A variant of authorization_pending error code, the authorization request
  /// is still pending and polling should continue, but the interval MUST be
  /// increased by 5 seconds for this and all subsequent requests
  slowDown('slow_down');

  /// The machine-readable code of the error as specified in the OAuth 2.0 spec.
  final String code;

  const TokenResponseErrorCode(this.code);
}

/// Represents error responses returned from OAuth2.0 endpoints
/// as defined in RFC 6749 Section 5.2.
class TokenErrorResponse {
  /// A single ASCII [error] code.
  TokenResponseErrorCode error;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  String? errorUri;

  /// REQUIRED if a "state" parameter was present in the client
  /// authorization request. The exact value received from the client.
  String? state;

  TokenErrorResponse({
    required this.error,
    this.errorDescription,
    this.errorUri,
    this.state,
  });

  factory TokenErrorResponse.fromJson(String input) {
    return TokenErrorResponse.fromMap(jsonDecode(input));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates an instance from a map.
  factory TokenErrorResponse.fromMap(Map<String, dynamic> json) {
    return TokenErrorResponse(
      error: TokenResponseErrorCode.values
          .firstWhere((e) => e.code == json['error']),
      errorDescription: json['error_description'],
      errorUri: json['error_uri'],
      state: json['state'],
    );
  }

  /// Converts the [TokenErrorResponse] to a map.
  Map<String, dynamic> toMap() {
    return {
      'error': error.code,
      if (errorDescription != null) 'error_description': errorDescription,
      if (errorUri != null) 'error_uri': errorUri,
      if (state != null) 'state': state,
    };
  }
}

/// Custom exception for handling OID4VC Exceptions.
class TokenResponseException implements Exception {
  /// see [TokenResponseErrorCode]
  final TokenResponseErrorCode errorCode;

  /// Optional text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  /// Values for the "error_description" parameter MUST NOT include
  /// characters outside the set %x20-21 / %x23-5B / %x5D-7E.
  final String? errorDescription;

  /// A URI identifying a human-readable web page with information about
  /// the error, used to provide the client developer with additional
  /// information about the error.
  final String? errorUri;

  /// REQUIRED if a "state" parameter was present in the client
  /// authorization request. The exact value received from the client.
  final String? state;

  TokenResponseException({
    required this.errorCode,
    this.errorDescription,
    this.errorUri,
    this.state,
  });

  @override
  String toString() {
    return 'OID4VCException: ${errorCode.code} - $errorDescription';
  }

  /// Creates an [TokenResponseException] from an [TokenErrorResponse].
  static TokenResponseException fromErrorResponse(TokenErrorResponse response) {
    return TokenResponseException(
      errorCode: response.error,
      errorDescription: response.errorDescription,
      errorUri: response.errorUri,
      state: response.state,
    );
  }
}

/// Exception thrown when there is an error in processing the token response.
class TokenUnknownResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  TokenUnknownResponseException({
    required this.message,
    required this.status,
    this.body,
    this.cause,
  });

  @override
  String toString() {
    final parts = ['TokenResponseException: $message', 'Status: $status'];

    if (body != null) {
      parts.add('Response Body: $body');
    }
    if (cause != null) {
      parts.add('Caused by: $cause');
    }
    return parts.join('\n');
  }
}
