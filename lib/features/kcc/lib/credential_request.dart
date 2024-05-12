import 'dart:convert';

/// Represents the request body sent to the PFI's credential endpoint.
/// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.2)
class CredentialRequest {
  /// REQUIRED when the credential_identifiers parameter was not returned from
  /// the Token Response. It MUST NOT be used otherwise. It is a String that
  /// determines the format of the Credential to be issued, which may determine
  /// the type and any other information related to the Credential to be issued.
  /// Credential Format Profiles consist of the Credential format specific
  /// parameters that are defined in Appendix A. When this parameter is used,
  /// the credential_identifier Credential Request parameter MUST NOT be present.
  /// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.2-2.1)
  String format;

  /// OPTIONAL. Contains the proof of possession of the cryptographic
  /// key material the issued Credential would be bound to. The proof object is
  /// REQUIRED if the proof_types_supported parameter is non-empty and present
  /// in the credential_configurations_supported parameter of the Issuer metadata
  /// for the requested Credential.
  ///
  /// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.2-2.2.2.1)
  ProofJwt proof;

  CredentialRequest({required this.format, required this.proof});

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'format': format,
      'proof': proof.toMap(),
    };
  }
}

/// [Reference](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-7.2.1.1)
class ProofJwt {
  String proofType = 'jwt';
  String jwt;

  ProofJwt({required this.jwt});

  Map<String, dynamic> toMap() {
    return {
      'proof_type': proofType,
      'jwt': jwt,
    };
  }
}

/// Exception thrown when a credential request fails.
class CredentialRequestException implements Exception {
  final String message;
  final Exception? cause;

  CredentialRequestException({required this.message, this.cause});

  @override
  String toString() {
    var result = 'CredentialRequestException: $message';
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}
