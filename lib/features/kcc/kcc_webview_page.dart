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
import 'package:web5/web5.dart';

class KccWebviewPage extends HookConsumerWidget {
  final Pfi pfi;
  final PresentationDefinition presentationDefinition;

  const KccWebviewPage({
    required this.pfi,
    required this.presentationDefinition,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const finish = 'finish.html';

    final idvRequest = useState<AsyncValue<IdvRequest>>(const AsyncLoading());
    final webViewController = useState<InAppWebViewController?>(null);

    final settings = InAppWebViewSettings(
      isInspectable: kDebugMode, // TODO: only enable for debug builds
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: 'camera; microphone',
      iframeAllowFullscreen: true,
    );

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () async => _loadWebView(context, ref, idvRequest, webViewController),
        );
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
            onRetry: () =>
                _loadWebView(context, ref, idvRequest, webViewController),
          ),
        ),
        data: (data) => InAppWebView(
          initialSettings: settings,
          onWebViewCreated: (controller) {
            webViewController.value = controller;

            final fullPath =
                Uri.parse(data.url).replace(scheme: 'https').toString();

            if (fullPath.contains(finish)) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KccRetrievalPage(
                    pfi: pfi,
                    idvRequest: data,
                  ),
                ),
              );
            } else {
              controller.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
            }
          },
          onLoadStop: (controller, url) async {
            if (url == null) {
              return;
            }

            if (url.path.contains(finish)) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KccRetrievalPage(
                    pfi: pfi,
                    idvRequest: data,
                  ),
                ),
              );

              if (context.mounted) {
                await _loadWebView(
                  context,
                  ref,
                  idvRequest,
                  webViewController,
                );
              }
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
      ),
    );
  }

  Future<void> _loadWebView(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<IdvRequest>> state,
    ValueNotifier<InAppWebViewController?> webViewController,
  ) async {
    state.value = const AsyncLoading();
    try {
      final idvRequest = await ref
          .read(kccIssuanceProvider)
          .getIdvRequest(pfi, presentationDefinition, ref.read(didProvider));

      if (context.mounted) {
        state.value = AsyncData(idvRequest);

        final fullPath =
            Uri.parse(idvRequest.url).replace(scheme: 'https').toString();
        await webViewController.value
            ?.loadUrl(urlRequest: URLRequest(url: WebUri(fullPath)));
      }
    } on Exception catch (e) {
      if (context.mounted) {
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
