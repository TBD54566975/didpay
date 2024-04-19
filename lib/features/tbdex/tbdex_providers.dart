import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.autoDispose<List<Offering>>((ref) async {
  try {
    // TODO(ethan-tbd): don't hardcode the DID
    final offerings = await TbdexHttpClient.getOfferings(
      'did:dht:74hg1efatndi8enx3e4z6c4u8ieh1xfkyay4ntg4dg1w6risu35y',
    );
    return offerings;
  } on Exception catch (e) {
    throw Exception('Failed to load offerings: $e');
  }
});

// TODO(ethan-tbd): add providers for other tbdex client methods below
