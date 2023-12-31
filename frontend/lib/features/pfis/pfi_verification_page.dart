import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:flutter_starter/features/pfis/pfi_confirmation_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5_flutter/web5_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class PfiVerificationPage extends HookConsumerWidget {
  final Pfi pfi;

  const PfiVerificationPage({required this.pfi, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const proof =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

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
            if (request.url.startsWith('didpay://kyc')) {
              _handleDidPay(context, request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    useEffect(() {
      Future.microtask(() async {
        final result = await DidDht.resolve(pfi.didUri);
        final widgetService = result.didDocument?.service
            ?.firstWhere((e) => e.type == 'kyc-widget');
        if (widgetService?.serviceEndpoint == null) {
          final snackBar = SnackBar(
            content: const Text('PFI does not support KYC widget'),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.error,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }

        final fullPath =
            '${widgetService?.serviceEndpoint}?proof=$proof&callback_uri=didpay://kyc';

        controller.loadRequest(Uri.parse(fullPath));
      });

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('PFI Verification')),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  void _handleDidPay(BuildContext context, String url) {
    final uri = Uri.parse(url);
    final transactionId = uri.queryParameters['transaction_id'];

    if (transactionId == null) {
      const snackBar = SnackBar(
        content: Text('KYC widget did not return transaction id'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PfiConfirmationPage(pfi: pfi, transactionId: transactionId),
      ),
    );
  }
}
