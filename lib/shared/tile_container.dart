import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TileContainer extends HookWidget {
  final Widget child;

  const TileContainer({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: Grid.tileHeight,
            child: Center(child: child),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
