import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentLinkWebviewPage extends HookConsumerWidget {
  final String paymentLink;
  final Future<void> Function() onSubmit;

  const PaymentLinkWebviewPage({
    required this.paymentLink,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    return Scaffold(
      appBar: AppBar(),
      body: InAppWebView(
        initialSettings: settings,
        onWebViewCreated: (c) {
          final url = Uri.parse(paymentLink);
          final fullPath = url.replace(scheme: 'https').toString();

          c.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
        },
        onLoadStop: (controller, url) async {
          if (url == null) {
            return;
          }

          if (url.path.contains('finish.html')) {
            await onSubmit();
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onPermissionRequest: (controller, permissionRequest) async {
          return PermissionResponse(
            action: PermissionResponseAction.GRANT,
          );
        },
      ),
    );
  }
}
