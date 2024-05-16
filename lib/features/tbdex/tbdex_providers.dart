import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_exceptions.dart';
import 'package:didpay/features/tbdex/transactions_notifier.dart';
import 'package:didpay/shared/http_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.autoDispose<List<Offering>>((ref) async {
  final pfis = ref.read(pfisProvider);
  final offerings = <Offering>[];

  for (final pfi in pfis) {
    final response = await TbdexHttpClient.listOfferings(pfi.did);
    if (response.statusCode.category == HttpStatus.success) {
      offerings.addAll(response.data!);
    }
  }

  return offerings;
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

final exchangeProvider = FutureProvider.family
    .autoDispose<Exchange, String>((ref, exchangeId) async {
  final did = ref.read(didProvider);
  final pfis = ref.read(pfisProvider);

  final response = await TbdexHttpClient.getExchange(
    did,
    pfis[0].did,
    exchangeId,
  );

  return response.statusCode.category == HttpStatus.success
      ? response.data!
      : throw ExchangeException(
          'failed to fetch exchange',
          response.statusCode,
        );
});

final exchangesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final did = ref.read(didProvider);
  final pfis = ref.read(pfisProvider);

  if (pfis.isEmpty) {
    return [];
  }

  final response = await TbdexHttpClient.listExchanges(
    did,
    pfis[0].did,
  );

  return response.statusCode.category == HttpStatus.success
      ? response.data!
      : throw ExchangesException(
          'failed to fetch exchanges',
          response.statusCode,
        );
});

final quoteProvider =
    AsyncNotifierProvider.autoDispose<QuoteAsyncNotifier, Quote?>(
  QuoteAsyncNotifier.new,
);

final transactionsProvider = AsyncNotifierProvider.autoDispose<
    TransactionsAsyncNotifier, List<Exchange>?>(
  TransactionsAsyncNotifier.new,
);
