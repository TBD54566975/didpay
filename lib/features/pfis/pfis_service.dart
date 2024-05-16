import 'package:didpay/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final pfisServiceProvider = Provider((_) => PfisService());

class PfisService {
  Future<Pfi> createPfi(String input) async {
    final Did did;
    try {
      did = Did.parse(input);
    } on Exception catch (e) {
      throw Exception('Invalid DID: $e');
    }

    final res = await DidResolver.resolve(did.uri);
    if (res.hasError()) {
      throw Exception(
        'Failed to resolve DID: ${res.didResolutionMetadata.error}',
      );
    }

    if (res.didDocument == null) {
      throw Exception('Malformed Resolution result: missing DID Document');
    }

    _getServiceEndpoint(res.didDocument!, 'PFI');
    _getServiceEndpoint(res.didDocument!, 'IDV');

    return Pfi(did: did.uri);
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
