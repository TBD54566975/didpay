import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/snackbar/snackbar_service.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModalManageItem {
  static Future<dynamic> show(
    BuildContext context,
    String title,
    String removeText,
    String copyText,
    Future<void> Function() onRemove,
  ) {
    final snackbarService = SnackbarService();

    return showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Grid.xxs),
            ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: copyText));

                  if (context.mounted) {
                    snackbarService.showSnackBar(
                      context,
                      Loc.of(context).copiedToClipboard,
                    );

                    Navigator.pop(context);
                  }
                },
              ),
              title: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Divider(
              color:
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
            ),
            ListTile(
              title: Center(
                child: Text(
                  removeText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () async {
                await onRemove();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            Divider(
              color:
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
            ),
            ListTile(
              title: Center(
                child: Text(
                  Loc.of(context).cancel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
