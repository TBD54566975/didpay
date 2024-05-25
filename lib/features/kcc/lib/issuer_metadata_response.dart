import 'dart:convert';

class IssuerMetadata {
  String credentialIssuer;
  Uri credentialEndpoint;
  CredentialConfigurationSupported credentialConfigurationSupported;

  IssuerMetadata({
    required this.credentialIssuer,
    required this.credentialEndpoint,
    required this.credentialConfigurationSupported,
  });

  Map<String, dynamic> toMap() {
    return {
      'credential_issuer': credentialIssuer,
      'credential_endpoint': credentialEndpoint,
      'credential_configurations_supported':
          credentialConfigurationSupported.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory IssuerMetadata.fromMap(Map<String, dynamic> map) {
    return IssuerMetadata(
      credentialIssuer: map['credential_issuer'],
      credentialEndpoint: Uri.parse(map['credential_endpoint'] as String),
      credentialConfigurationSupported:
          CredentialConfigurationSupported.fromMap(
        map['credential_configurations_supported'],
      ),
    );
  }

  factory IssuerMetadata.fromJson(String source) =>
      IssuerMetadata.fromMap(json.decode(source));
}

class CredentialConfigurationSupported {
  String format;
  List<String> cryptoBindingMethodsSupported;
  List<String> cryptoSigningAlgsSupported;
  ProofTypeSupported proofTypesSupported;

  CredentialConfigurationSupported({
    required this.format,
    required this.cryptoBindingMethodsSupported,
    required this.cryptoSigningAlgsSupported,
    required this.proofTypesSupported,
  });

  Map<String, dynamic> toMap() {
    return {
      'format': format,
      'cryptographic_binding_methods_supported': cryptoBindingMethodsSupported,
      'credential_signing_alg_values_supported': cryptoSigningAlgsSupported,
      'proof_types_supported': proofTypesSupported.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory CredentialConfigurationSupported.fromMap(Map<String, dynamic> map) {
    return CredentialConfigurationSupported(
      format: map['format'],
      cryptoBindingMethodsSupported:
          List<String>.from(map['cryptographic_binding_methods_supported']),
      cryptoSigningAlgsSupported:
          List<String>.from(map['credential_signing_alg_values_supported']),
      proofTypesSupported:
          ProofTypeSupported.fromMap(map['proof_types_supported']),
    );
  }

  factory CredentialConfigurationSupported.fromJson(String source) =>
      CredentialConfigurationSupported.fromMap(json.decode(source));
}

class ProofTypeSupported {
  ProofType jwt;

  ProofTypeSupported({
    required this.jwt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jwt': jwt.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory ProofTypeSupported.fromMap(Map<String, dynamic> map) {
    return ProofTypeSupported(
      jwt: ProofType.fromMap(map['jwt']),
    );
  }

  factory ProofTypeSupported.fromJson(String source) =>
      ProofTypeSupported.fromMap(json.decode(source));
}

class ProofType {
  List<String> proofSigningAlgsSupported;

  ProofType({
    required this.proofSigningAlgsSupported,
  });

  Map<String, dynamic> toMap() {
    return {
      'proof_signing_alg_values_supported': proofSigningAlgsSupported,
    };
  }

  String toJson() => json.encode(toMap());

  factory ProofType.fromMap(Map<String, dynamic> map) {
    return ProofType(
      proofSigningAlgsSupported:
          List<String>.from(map['proof_signing_alg_values_supported']),
    );
  }

  factory ProofType.fromJson(String source) =>
      ProofType.fromMap(json.decode(source));
}

/// Exception thrown when there is an error in processing the issuer metadata response.
class IssuerMetadataResponseException implements Exception {
  final String message;
  final int status;
  final String? body;
  final Exception? cause;

  IssuerMetadataResponseException({
    required this.message,
    required this.status,
    this.body,
    this.cause,
  });

  @override
  String toString() {
    final parts = [
      'IssuerMetadataResponseException: $message',
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
