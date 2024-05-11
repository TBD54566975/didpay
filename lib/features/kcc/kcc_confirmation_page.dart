import 'package:didpay/features/kcc/idv_request.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KccConfirmationPage extends HookConsumerWidget {
  final NuPfi pfi;
  final IdvRequest idvRequest;

  const KccConfirmationPage({
    required this.pfi,
    required this.idvRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    useEffect(
      () {
        Future.delayed(const Duration(seconds: 2), () {
          isLoading.value = false;
        });
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: Grid.xl),
                        Text(
                          'Moe town',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: Grid.xs),
                        Icon(
                          Icons.check_circle,
                          size: Grid.xl,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) => route.settings.name == 'kccDialog',
                        );

                        Navigator.of(context).pop();
                      },
                      child: Text(Loc.of(context).done),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
