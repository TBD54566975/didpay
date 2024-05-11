import 'dart:convert';

/// Represents an access token request as described in [RFC 6749 Section 4.1.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.3).
/// This includes fields specific to the OID4VCI per [Section 6.2](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.1)
class TokenRequest {
  /// The code representing the authorization to obtain Credentials of a certain type.
  /// This parameter MUST be present if the grant_type is
  /// urn:ietf:params:oauth:grant-type:pre-authorized_code.
  String preAuthCode;

  /// String value containing a Transaction Code. This value MUST be present
  /// if a tx_code object was present in the Credential Offer
  /// (including if the object was empty). This parameter MUST only be used
  /// if the grant_type is urn:ietf:params:oauth:grant-type:pre-authorized_code.
  String grantType;

  /// For the Pre-Authorized Code Grant Type, authentication of the Client is
  /// OPTIONAL, as described in Section 3.2.1 of OAuth 2.0 RFC6749, and,
  /// consequently, the client_id parameter is only needed when a form of
  /// Client Authentication that relies on this parameter is used.
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-6.1-5)
  String? clientId;

  TokenRequest({
    required this.preAuthCode,
    required this.grantType,
    this.clientId,
  });

  factory TokenRequest.fromMap(Map<String, dynamic> json) {
    return TokenRequest(
      preAuthCode: json['pre-authorized_code'] as String,
      grantType: json['grant_type'] as String,
      clientId: json['client_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pre-authorized_code': preAuthCode,
      'grant_type': grantType,
      'client_id': clientId,
    };
  }
}

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

/// Exception thrown when a token request fails.
class TokenRequestException implements Exception {
  final String message;
  final Exception? cause;

  TokenRequestException({required this.message, this.cause});

  @override
  String toString() {
    var result = 'TokenRequestException: $message';
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}

/// Exception thrown when there is an error in processing the token response.
class TokenResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  TokenResponseException({
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
