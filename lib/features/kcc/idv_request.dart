import 'dart:convert';

class IdvRequest {
  String url;
  CredentialOffer credentialOffer;

  IdvRequest({required this.url, required this.credentialOffer});

  factory IdvRequest.fromJson(String input) {
    Map<String, dynamic> data = jsonDecode(input);
    return IdvRequest(
      url: data['url'],
      credentialOffer: CredentialOffer.fromJson(data['credential_offer']),
    );
  }
}

class CredentialOffer {
  String credentialIssuerUrl;
  List<String> credentialConfigurationIds;
  Grants grants;

  String get preAuthorizedCode => grants.preAuthorizedCode.preAuthorizedCode;
  String get grantType =>
      'urn:ietf:params:oauth:grant-type:pre-authorized_code';

  CredentialOffer({
    required this.credentialIssuerUrl,
    required this.credentialConfigurationIds,
    required this.grants,
  });

  factory CredentialOffer.fromJson(Map<String, dynamic> data) {
    return CredentialOffer(
      credentialIssuerUrl: data['credential_issuer'],
      credentialConfigurationIds:
          List<String>.from(data['credential_configuration_ids']),
      grants: Grants.fromJson(data['grants']),
    );
  }
}

class Grants {
  PreAuthorizedCode preAuthorizedCode;

  Grants({required this.preAuthorizedCode});

  factory Grants.fromJson(Map<String, dynamic> data) {
    return Grants(
      preAuthorizedCode: PreAuthorizedCode.fromJson(
        data['urn:ietf:params:oauth:grant-type:pre-authorized_code'],
      ),
    );
  }
}

class PreAuthorizedCode {
  String preAuthorizedCode;

  PreAuthorizedCode({required this.preAuthorizedCode});

  factory PreAuthorizedCode.fromJson(Map<String, dynamic> data) {
    return PreAuthorizedCode(
      preAuthorizedCode: data['pre-authorized_code'],
    );
  }
}
