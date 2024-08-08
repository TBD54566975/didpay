import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';

class SnackbarService {
  void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        duration: duration,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: ShapeBorder.lerp(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Grid.xs),
          ),
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Grid.xs),
          ),
          1,
        ),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Theme.of(context).colorScheme.onSurface,
        margin: const EdgeInsets.symmetric(horizontal: Grid.xl),
      ),
    );
  }
}
