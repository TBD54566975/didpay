import 'package:url_launcher/url_launcher.dart';

class LinkingService {
  Future<void> launchWallet(
    Map<String, dynamic>? oidcParams,
    String? walletUrl,
  ) async {
    var queryString = '';

    if (oidcParams != null) {
      queryString = oidcParams.entries
          .map(
            (entry) =>
                '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
          )
          .join('&');
    }

    final url = Uri.parse('$walletUrl?$queryString');

    final linkDidOpen =
        await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!linkDidOpen) {
      throw Exception('Could not launch $url');
    }
  }
}
