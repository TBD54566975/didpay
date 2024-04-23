import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.autoDispose<List<Offering>>((ref) async {
  try {
    // TODO(ethan-tbd): don't hardcode the DID
    final offerings = await TbdexHttpClient.getOfferings(
      'did:web:localhost%3A8892:ingress',
    );
    return offerings;
  } on Exception catch (e) {
    throw Exception('Failed to load offerings: $e');
  }
});

// TODO(ethan-tbd): add providers for other tbdex client methods below
