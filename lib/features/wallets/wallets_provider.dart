import 'package:didpay/features/wallets/wallet.dart';
import 'package:didpay/features/wallets/wallet_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final AutoDisposeFutureProvider<List<Wallet>> walletsProvider =
    FutureProvider.autoDispose((ref) async {
  final walletService = ref.read(walletServiceProvider);
  final fetchedWallets = await walletService.getWallets();

  return fetchedWallets;
});
