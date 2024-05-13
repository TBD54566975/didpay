import 'package:didpay/features/kcc/kcc_confirmation_page.dart';
import 'package:didpay/features/kcc/providers.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KccWebviewPage extends StatelessWidget {
  final NuPfi pfi;

  const KccWebviewPage({
    required this.pfi,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PFI Verification')),
      body: Consumer(
        builder: (context, ref, _) {
          final idvRequest = ref.watch(idvRequestProvider(pfi));

          return idvRequest.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (idvRequest) {
              return InAppWebView(
                initialSettings: settings,
                onWebViewCreated: (c) {
                  final fullPath = Uri.parse(idvRequest.url)
                      .replace(port: 5173, scheme: 'https')
                      .toString();

                  c.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
                },
                onCloseWindow: (controller) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => KccConfirmationPage(
                        pfi: pfi,
                        idvRequest: idvRequest,
                      ),
                    ),
                  );
                },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
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
            error: (e, s) =>
                const Center(child: Text('Failed to load IDV request')),
          );
        },
      ),
    );
  }
}
