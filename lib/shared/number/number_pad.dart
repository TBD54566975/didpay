import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NumberPad extends HookWidget {
  final Function(String) onKeyPressed;

  const NumberPad({
    required this.onKeyPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pressedKey = useState<String>('');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRow(context, ['1', '2', '3'], pressedKey),
          _buildRow(context, ['4', '5', '6'], pressedKey),
          _buildRow(context, ['7', '8', '9'], pressedKey),
          _buildRow(context, ['.', '0', '<'], pressedKey),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<String> keys,
    ValueNotifier<String> pressedKey,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: keys.map((key) {
          return Flexible(
            child: _NumberPadKey(
              text: key,
              onKeyPressed: onKeyPressed,
            ),
          );
        }).toList(),
      );
}

class _NumberPadKey extends HookWidget {
  final String text;
  final Function(String) onKeyPressed;

  const _NumberPadKey({
    required this.text,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const keyHeight = 60.0;
    final keyWidth = screenWidth / 4;

    const defaultFontSize = 24.0;
    const selectedFontSize = 44.0;

    final keySize = useState(defaultFontSize);

    return GestureDetector(
      onTapDown: (_) => keySize.value = selectedFontSize,
      onTapCancel: () => keySize.value = defaultFontSize,
      onTapUp: (_) {
        keySize.value = defaultFontSize;
        onKeyPressed(text);
      },
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: keyHeight,
        width: keyWidth,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 100),
          style: TextStyle(
            fontSize: keySize.value,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Center(
            child: Text(
              text,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}
