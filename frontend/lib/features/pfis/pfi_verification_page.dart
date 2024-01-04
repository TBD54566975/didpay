import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class PfiVerificationPage extends StatelessWidget {
  final String widgetUri;

  const PfiVerificationPage({required this.widgetUri, super.key});

  @override
  Widget build(BuildContext context) {
    final fullPath = '$widgetUri?proof=moegrammer&callback_uri=didpay://kyc';
    final controller = WebViewController()
      ..setBackgroundColor(Theme.of(context).colorScheme.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('didpay://')) {
              _handleDidPay(context, request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(fullPath));

    return Scaffold(
      appBar: AppBar(title: const Text('PFI Verification')),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  void _handleDidPay(BuildContext context, String url) {
    final snackBar = SnackBar(
      content: Text('Received custom URL callback: $url'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pop();
  }
}
