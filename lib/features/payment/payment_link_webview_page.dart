import 'package:didpay/features/app/app.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentLinkWebviewPage extends HookConsumerWidget {
  const PaymentLinkWebviewPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentLink = useState<AsyncValue<String>>(const AsyncLoading());

    paymentLink.value = const AsyncData('https://square.link/u/fKCvsjLg');

    final settings = InAppWebViewSettings(
      isInspectable:
          kDebugMode, // TODO(mistermoe): only enable for debug builds
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: paymentLink.value.when(
        loading: () => LoadingMessage(message: Loc.of(context).startingIdv),
        error: (error, stackTrace) => SafeArea(
          child: ErrorMessage(
            message: error.toString(),
            onRetry: () => print('retrying...'),
          ),
        ),
        data: (url) {
          return InAppWebView(
            initialSettings: settings,
            onWebViewCreated: (c) {
              final fullPath =
                  Uri.parse(url).replace(scheme: 'https').toString();

              c.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
            },
            onLoadStart: (controller, url) {
              print('WOO LOADINGGG $url');
              if (url.toString().contains('finish.html')) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const App(),
                  ),
                );
              }
            },
            onCloseWindow: (controller) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const App(),
                ),
              );
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
          );
        },
      ),
    );
  }
}
