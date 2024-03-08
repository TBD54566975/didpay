import 'dart:convert';
import 'package:didpay/features/wallets/wallet.dart';
import 'package:http/http.dart' as http;

class WalletService {
  Future<List<Wallet>> getWallets() async {
    final response =
        await http.get(Uri.parse('https://tbd54566975.github.io/wallets.json'));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load wallets from HTTP, error code: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List<dynamic> walletsJson = data['wallets'];
    final List<Wallet> wallets = walletsJson
        .map((walletJson) => Wallet.fromJson(walletJson))
        .cast<Wallet>()
        .toList();

    return wallets;
  }
}
