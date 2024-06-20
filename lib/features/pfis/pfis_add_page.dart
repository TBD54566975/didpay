import 'package:didpay/features/did/did_form.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirmation_message.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfisAddPage extends HookConsumerWidget {
  const PfisAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfi = useState<AsyncValue<Pfi>?>(null);

    final pfiDidController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: pfi.value != null
            ? pfi.value!.when(
                data: (_) =>
                    ConfirmationMessage(message: Loc.of(context).pfiAdded),
                loading: () =>
                    LoadingMessage(message: Loc.of(context).addingPfi),
                error: (error, _) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => _addPfi(ref, pfiDidController.text, pfi),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Header(
                    title: Loc.of(context).addAPfi,
                    subtitle: Loc.of(context).makeSureInfoIsCorrect,
                  ),
                  Expanded(
                    child: DidForm(
                      buttonTitle: Loc.of(context).add,
                      onSubmit: (did) => _addPfi(ref, did, pfi),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _addPfi(
    WidgetRef ref,
    String did,
    ValueNotifier<AsyncValue<Pfi>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await ref
          .read(pfisProvider.notifier)
          .add(did)
          .then((pfi) => state.value = AsyncData(pfi));
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
