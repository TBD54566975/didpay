import 'package:didpay/features/onboarding/agreement_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfiPage extends HookConsumerWidget {
  const PfiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPfi = useState<Pfi?>(null);

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () => ref.read(pfisProvider.notifier).reload(),
        );
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).getStartedWithAPfi,
              Loc.of(context).selectAPfi,
            ),
            Expanded(
              child: _buildPfiList(context, ref, selectedPfi),
            ),
            const SizedBox(height: Grid.xs),
            _buildNextButton(context, ref, selectedPfi.value),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Grid.side,
          vertical: Grid.xs,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildPfiList(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<Pfi?> selectedPfi,
  ) =>
      ref.watch(pfisProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(context, ref, error),
            data: (pfis) => ListView(
              children: pfis
                  .map(
                    (pfi) => ListTile(
                      title: Text(
                        pfi.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      subtitle: Text(pfi.didUri),
                      trailing: (selectedPfi.value == pfi)
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () async {
                        selectedPfi.value = pfi;
                      },
                    ),
                  )
                  .toList(),
            ),
          );

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error.toString()),
            const SizedBox(height: Grid.xxs),
            FilledButton(
              onPressed: () {
                ref.read(pfisProvider.notifier).reload();
              },
              child: const Text('Reload'),
            ),
          ],
        ),
      );

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
    Pfi? selectedPfi,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: selectedPfi == null
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AgreementPage(
                        pfi: selectedPfi,
                      ),
                    ),
                  );
                },
          child: Text(Loc.of(context).next),
        ),
      );
}
