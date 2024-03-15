import 'package:url_launcher/url_launcher.dart';

class LinkingService {
  Future<void> launchWallet(
      Map<String, dynamic>? oidcParams, String? walletUrl) async {
    String queryString = '';

    if (oidcParams != null) {
      queryString = oidcParams.entries
          .map((entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
          .join('&');
    }

    final Uri url = Uri.parse('$walletUrl?$queryString');

    final linkDidOpen =
        await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!linkDidOpen) {
      throw 'Could not launch $url';
    }
  }
}
