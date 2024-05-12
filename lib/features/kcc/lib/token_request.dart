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
