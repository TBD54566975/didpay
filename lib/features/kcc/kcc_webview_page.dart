import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/kcc/idv_request.dart';
import 'package:didpay/features/kcc/kcc_confirmation_page.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KccWebviewPage extends HookConsumerWidget {
  final NuPfi pfi;

  const KccWebviewPage({
    required this.pfi,
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

    final idvRequest = useState<IdvRequest?>(null);

    useEffect(
      () {
        Future.microtask(() async {
          final kccIssuance = ref.read(kccIssuanceServiceProvider);
          final bearerDid = ref.read(didProvider);

          idvRequest.value = await kccIssuance.getIdvRequest(pfi, bearerDid);
        });

        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PFI Verification')),
      body: idvRequest.value == null
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
              initialSettings: settings,
              onWebViewCreated: (c) {
                final fullPath = Uri.parse(idvRequest.value!.url)
                    .replace(port: 5173, scheme: 'https')
                    .toString();

                c.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
              },
              onCloseWindow: (controller) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KccConfirmationPage(
                      pfi: pfi,
                      idvRequest: idvRequest.value!,
                    ),
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
            ),
    );
  }
}
