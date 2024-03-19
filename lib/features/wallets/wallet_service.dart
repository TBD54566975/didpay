import 'dart:convert';
import 'package:didpay/features/wallets/wallet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final walletServiceProvider = Provider<WalletService>((ref) => WalletService());

class WalletService {
  Future<List<Wallet>> getWallets() async {
    final response =
        await http.get(Uri.parse('https://tbd54566975.github.io/wallets.json'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load wallets from HTTP, error code: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return (data['wallets'] as List<dynamic>)
        .map((item) => Wallet.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
