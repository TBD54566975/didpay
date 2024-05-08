import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.autoDispose<List<Offering>>((ref) async {
  try {
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);
    final offerings = await TbdexHttpClient.listOfferings(pfi?.didUri ?? '');
    return offerings;
  } on Exception catch (e) {
    throw Exception('Failed to load offerings: $e');
  }
});

final rfqProvider =
    FutureProvider.family.autoDispose<void, Rfq>((ref, rfq) async {
  try {
    final did = ref.read(didProvider);
    await rfq.sign(did);

    await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);
  } on Exception catch (e) {
    throw Exception('Failed to send rfq: $e');
  }
});

final quoteProvider =
    AsyncNotifierProvider.autoDispose<QuoteAsyncNotifier, Quote?>(
  QuoteAsyncNotifier.new,
);
