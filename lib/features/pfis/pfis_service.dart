import 'package:didpay/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final pfisServiceProvider = Provider((_) => PfisService());

class PfisService {
  Future<Pfi> createPfi(String input) async {
    final did = _parseDid(input);
    final res = await _resolveDid(did);
    final didDocument = _getDidDocument(res);

    final pfiEndpoint = _getServiceEndpoint(didDocument, 'PFI');
    final idvEndpoint = _getServiceEndpoint(didDocument, 'IDV');

    return Pfi(
      did: did.uri,
      tbdexServiceEndpoint: pfiEndpoint,
      idvServiceEndpoint: idvEndpoint,
    );
  }

  static Did _parseDid(String input) {
    try {
      return Did.parse(input);
    } on Exception catch (e) {
      throw Exception('Invalid DID: $e');
    }
  }

  static Future<DidResolutionResult> _resolveDid(Did did) async {
    final resp = await DidResolver.resolve(did.uri);
    if (resp.hasError()) {
      throw Exception(
        'Failed to resolve DID: ${resp.didResolutionMetadata.error}',
      );
    }
    return resp;
  }

  static DidDocument _getDidDocument(DidResolutionResult resp) {
    if (resp.didDocument == null) {
      throw Exception('Malformed Resolution result: missing DID Document');
    }
    return resp.didDocument!;
  }

  static Uri _getServiceEndpoint(DidDocument didDocument, String serviceType) {
    final service = didDocument.service?.firstWhere(
      (svc) => svc.type == serviceType,
      orElse: () => throw Exception('DID does not have a $serviceType service'),
    );

    if (service == null || service.serviceEndpoint.isEmpty) {
      throw Exception(
        'Malformed $serviceType service: missing service endpoint',
      );
    }

    return Uri.parse(service.serviceEndpoint.first);
  }
}
