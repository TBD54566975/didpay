import 'dart:async';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/kcc/kcc_retrieval_page.dart';
import 'package:didpay/features/kcc/lib/idv_request.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KccWebviewPage extends HookConsumerWidget {
  final Pfi pfi;

  const KccWebviewPage({
    required this.pfi,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bearerDid = ref.watch(didProvider);
    final kccIssuanceService = ref.watch(kccIssuanceProvider);
    final idvRequest = useState<AsyncValue<IdvRequest>>(const AsyncLoading());

    final settings = InAppWebViewSettings(
      isInspectable: kDebugMode, // TODO: only enable for debug builds
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    useEffect(
      () {
        Future.microtask(() async {
          try {
            final value =
                await kccIssuanceService.getIdvRequest(pfi, bearerDid);
            idvRequest.value = AsyncData(value);
          } on Exception catch (e, stackTrace) {
            idvRequest.value = AsyncError(e, stackTrace);
          }
        });

        return;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PFI Verification')),
      body: SafeArea(
        child: idvRequest.value.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error - $error')),
          data: (data) {
            return InAppWebView(
              initialSettings: settings,
              onWebViewCreated: (c) {
                final fullPath = Uri.parse(data.url)
                    .replace(port: 5173, scheme: 'https')
                    .toString();

                c.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
              },
              onCloseWindow: (controller) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KccRetrievalPage(
                      pfi: pfi,
                      idvRequest: data,
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
            );
          },
        ),
      ),
    );
  }
}
