import 'package:web5/web5.dart';

class NuPfi {
  final Did did;
  final DidDocument didDocument;
  final Uri tbdexServiceEndpoint;
  final Uri idvServiceEndpoint;

  NuPfi({
    required this.did,
    required this.didDocument,
    required this.tbdexServiceEndpoint,
    required this.idvServiceEndpoint,
  });

  static Future<NuPfi> fromDid(String input) async {
    Did did;
    try {
      did = Did.parse(input);
    } on Exception catch (e) {
      throw Exception('Invalid DID: $e');
    }

    DidResolutionResult resp;
    try {
      resp = await DidResolver.resolve(input);
      if (resp.hasError()) {
        throw Exception(
          'Failed to resolve DID: ${resp.didResolutionMetadata.error}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to resolve PFI DID: $e');
    }

    return NuPfi(
      did: did,
      didDocument: resp.didDocument!,
      idvServiceEndpoint: _getServiceEndpoint(resp.didDocument!, 'IDV'),
      tbdexServiceEndpoint: _getServiceEndpoint(resp.didDocument!, 'PFI'),
    );
  }

  static Uri _getServiceEndpoint(DidDocument didDocument, String serviceType) {
    final service = didDocument.service!.firstWhere(
      (svc) => svc.type == serviceType,
      orElse: () => throw Exception('DID does not have a $serviceType service'),
    );

    if (service.serviceEndpoint.isEmpty) {
      throw Exception(
        'Malformed $serviceType service: missing service endpoint',
      );
    }

    try {
      return Uri.parse(service.serviceEndpoint[0]);
    } on Exception catch (e) {
      throw Exception('PFI has malformed IDV service: $e');
    }
  }
}

class Pfi {
  final String id;
  final String name;
  final String didUri;

  const Pfi({
    required this.id,
    required this.name,
    required this.didUri,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'didUri': didUri,
    };
  }

  factory Pfi.fromJson(Map<String, dynamic> json) {
    return Pfi(
      id: json['id'],
      name: json['name'],
      didUri: json['didUri'],
    );
  }
}
