import 'package:didpay/features/vcs/vc_form.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirmation_message.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VcsAddPage extends HookConsumerWidget {
  const VcsAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = useState<AsyncValue<String>?>(null);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: vc.value != null
            ? vc.value!.when(
                data: (_) => ConfirmationMessage(
                  message: Loc.of(context).credentialAdded,
                ),
                loading: () =>
                    LoadingMessage(message: Loc.of(context).addingCredential),
                error: (error, _) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => vc.value = null,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Header(
                    title: Loc.of(context).addACredential,
                    subtitle: Loc.of(context).enterACredentialJwt,
                  ),
                  Expanded(
                    child: VcsForm(
                      buttonTitle: Loc.of(context).add,
                      onSubmit: (vcJwt) async =>
                          _addCredential(context, ref, vcJwt, vc),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _addCredential(
    BuildContext context,
    WidgetRef ref,
    String vcJwt,
    ValueNotifier<AsyncValue<String>?> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      final credential = await ref.read(vcsProvider.notifier).addJwt(vcJwt);

      if (context.mounted) {
        state.value = AsyncData(credential);
      }
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
