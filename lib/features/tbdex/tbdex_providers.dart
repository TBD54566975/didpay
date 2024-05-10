import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_exceptions.dart';
import 'package:didpay/shared/http_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.autoDispose<List<Offering>>((ref) async {
  final country = ref.read(countryProvider);
  final pfi = Config.getPfi(country);

  final response = await TbdexHttpClient.listOfferings(pfi?.didUri ?? '');

  return response.statusCode.category == HttpStatus.success
      ? response.data!
      : throw OfferingException(
          'failed to fetch offerings',
          response.statusCode,
        );
});

final rfqProvider =
    FutureProvider.family.autoDispose<void, Rfq>((ref, rfq) async {
  final did = ref.read(didProvider);
  await rfq.sign(did);

  final response =
      await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);

  if (response.statusCode.category != HttpStatus.success) {
    throw RfqException('failed to send rfq', response.statusCode);
  }
});

final quoteProvider =
    AsyncNotifierProvider.autoDispose<QuoteAsyncNotifier, Quote?>(
  QuoteAsyncNotifier.new,
);
