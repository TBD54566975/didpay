import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthWidgetPage extends StatelessWidget {
  const AuthWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setBackgroundColor(Theme.of(context).colorScheme.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('didpay://')) {
              _handleCallback(request.url, context);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tbd.website'));

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Widget')),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  void _handleCallback(String url, BuildContext context) {
    // DIDPay stuff maybe
  }
}
