import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/pfis/pfi_verification_page.dart';
import 'package:flutter_starter/features/pfis/pfis_notifier.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfisPage extends HookConsumerWidget {
  const PfisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.delayed(Duration.zero, () {
        ref.read(pfisProvider.notifier).reload();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).selectYourRegion)),
      body: ref.watch(pfisProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(context, ref, error),
            data: (pfis) => ListView(
              children: pfis
                  .map(
                    (pfi) => ListTile(
                      title: Text(pfi.name),
                      subtitle: Text(pfi.didUri),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PfiVerificationPage(pfi: pfi),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
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
        )
      ],
    ));
  }
}
