import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/pending_page.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddPfiConfirmationPage extends HookConsumerWidget {
  final String did;

  const AddPfiConfirmationPage({
    required this.did,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPfiState = useState<AsyncValue<Pfi>>(const AsyncLoading());

    useEffect(
      () {
        _addPfi(context, ref, addPfiState);
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: addPfiState.value.when(
          data: (pfi) => SuccessPage(text: Loc.of(context).pfiAdded),
          loading: () => PendingPage(text: Loc.of(context).addingPfi),
          error: (error, _) => Text('Error: $error'),
        ),
      ),
    );
  }

  void _addPfi(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Pfi>> state,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(pfisProvider.notifier)
        .add(did)
        .then((pfi) => state.value = AsyncData(pfi))
        .onError((error, stackTrace) {
      state.value = AsyncError(
        error ?? Exception('Unable to resolve add PFI'),
        stackTrace,
      );
      throw Exception();
    });
  }
}
