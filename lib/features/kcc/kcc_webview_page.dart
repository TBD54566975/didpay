import 'dart:async';

import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/kcc/kcc_retrieval_page.dart';
import 'package:didpay/features/kcc/lib/idv_request.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/loading_message.dart';
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
    final idvRequest = useState<AsyncValue<IdvRequest>>(const AsyncLoading());

    final settings = InAppWebViewSettings(
      isInspectable:
          kDebugMode, // TODO(mistermoe): only enable for debug builds
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    useEffect(
      () {
        Future.microtask(() async => _getIdvRequest(context, ref, idvRequest));
        return null;
      },
      [],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: idvRequest.value.when(
        loading: () => LoadingMessage(message: Loc.of(context).startingIdv),
        error: (error, stackTrace) => SafeArea(
          child: ErrorMessage(
            message: error.toString(),
            onRetry: () => _getIdvRequest(context, ref, idvRequest),
          ),
        ),
        data: (data) {
          return InAppWebView(
            initialSettings: settings,
            onWebViewCreated: (controller) {
              // TODO(mistermoe): this url needs to be fixed on our PFI side
              final fullPath =
                  Uri.parse(data.url).replace(scheme: 'https').toString();

              controller.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
            },
            onLoadStop: (controller, url) async {
              if (url == null) {
                return;
              }

              if (url.path.contains('finish.html')) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KccRetrievalPage(
                      pfi: pfi,
                      idvRequest: data,
                    ),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              }
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
    );
  }

  Future<void> _getIdvRequest(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<IdvRequest>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      final idvRequest = await ref
          .read(kccIssuanceProvider)
          .getIdvRequest(pfi, ref.read(didProvider));

      if (context.mounted) {
        state.value = AsyncData(idvRequest);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
