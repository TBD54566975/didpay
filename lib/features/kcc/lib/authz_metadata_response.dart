import 'dart:convert';

/// Represents the authorization metadata as described in [RFC 8414 Section 3.1](https://datatracker.ietf.org/doc/html/rfc8414#section-3.1).
class AuthorizationMetadata {
  /// The issuer of the authorization metadata.
  String issuer;

  /// The token endpoint of the authorization metadata.
  Uri tokenEndpoint;

  AuthorizationMetadata({
    required this.issuer,
    required this.tokenEndpoint,
  });

  factory AuthorizationMetadata.fromJson(String input) {
    return AuthorizationMetadata.fromMap(json.decode(input));
  }

  factory AuthorizationMetadata.fromMap(Map<String, dynamic> json) {
    return AuthorizationMetadata(
      issuer: json['issuer'] as String,
      tokenEndpoint: Uri.parse(json['token_endpoint'] as String),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'issuer': issuer,
      'token_endpoint': tokenEndpoint.toString(),
    };
  }
}

/// Exception thrown when there is an error in processing the deferred credential
/// response.
class AuthorizationMetadataResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  AuthorizationMetadataResponseException({
    required this.message,
    required this.status,
    this.body,
    this.cause,
  });

  @override
  String toString() {
    final parts = [
      'AuthorizationMetadataResponseException: $message',
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
