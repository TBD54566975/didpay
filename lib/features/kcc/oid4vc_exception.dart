import 'dart:convert';

/// Enum representing OAuth 2.0 error codes as defined in [RFC 6749 Section 5.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
/// In addition to the error codes added in the [OID4VC spec](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.3).
enum OID4VCErrorCode {
  /// The request is missing a required parameter, includes an
  /// unsupported parameter value (other than grant type),
  /// repeats a parameter, includes multiple credentials,
  /// utilizes more than one mechanism for authenticating the
  /// client, or is otherwise malformed.
  invalidRequest('invalid_request'),

  /// The client is not authorized to request an authorization
  /// code using this method.
  unauthorizedClient('unauthorized_client'),

  /// The resource owner or authorization server denied the request.
  accessDenied('access_denied'),

  /// The authorization server does not support obtaining an
  /// authorization code using this method.
  unsupportedResponseType('unsupported_response_type'),

  /// The requested scope is invalid, unknown, or malformed.
  invalidScope('invalid_scope'),

  /// The authorization server encountered an unexpected condition that
  /// prevented it from fulfilling the request. (This error code is needed
  /// because a 500 Internal Server Error HTTP status code cannot
  /// be returned to the client via an HTTP redirect.)
  serverError('server_error'),

  /// The authorization server is currently unable to handle the request
  /// due to a temporary overloading or maintenance of the server.
  /// (This error code is needed because a 503 Service Unavailable HTTP
  /// status code cannot be returned to the client via an HTTP redirect.)
  temporarilyUnavailable('temporarily_unavailable'),

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

  const OID4VCErrorCode(this.code);
}

/// Represents error responses returned from OAuth2.0 endpoints
/// as defined in RFC 6749 Section 5.2.
class OID4VCErrorResponse {
  /// A single ASCII [error] code.
  OID4VCErrorCode error;

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

  OID4VCErrorResponse({
    required this.error,
    this.errorDescription,
    this.errorUri,
    this.state,
  });

  factory OID4VCErrorResponse.fromJson(String input) {
    return OID4VCErrorResponse.fromMap(jsonDecode(input));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  /// Creates an instance from a map.
  factory OID4VCErrorResponse.fromMap(Map<String, dynamic> json) {
    return OID4VCErrorResponse(
      error: OID4VCErrorCode.values.firstWhere((e) => e.code == json['error']),
      errorDescription: json['error_description'],
      errorUri: json['error_uri'],
      state: json['state'],
    );
  }

  /// Converts the [OID4VCErrorResponse] to a map.
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
class OID4VCException implements Exception {
  /// see [OID4VCErrorCode]
  final OID4VCErrorCode errorCode;

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

  OID4VCException({
    required this.errorCode,
    this.errorDescription,
    this.errorUri,
    this.state,
  });

  @override
  String toString() {
    return 'OID4VCException: ${errorCode.code} - $errorDescription';
  }

  /// Creates an [OID4VCException] from an [OID4VCErrorResponse].
  static OID4VCException fromErrorResponse(OID4VCErrorResponse response) {
    return OID4VCException(
      errorCode: response.error,
      errorDescription: response.errorDescription,
      errorUri: response.errorUri,
      state: response.state,
    );
  }
}