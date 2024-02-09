import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/shared/theme/grid.dart';

class NumberPad extends HookWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDeletePressed;

  const NumberPad({
    required this.onKeyPressed,
    required this.onDeletePressed,
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
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((key) {
        return NumberPadKey(
          title: key,
          onKeyPressed: onKeyPressed,
          onDeletePressed: onDeletePressed,
        );
      }).toList(),
    );
  }
}

class NumberPadKey extends HookWidget {
  final String title;
  final Function(String) onKeyPressed;
  final VoidCallback onDeletePressed;

  const NumberPadKey({
    required this.title,
    required this.onKeyPressed,
    required this.onDeletePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const keyHeight = 64.0;
    const keyWidth = 93.0;
    const defaultFontSize = 24.0;
    const selectedFontSize = 44.0;

    final keySize = useState(defaultFontSize);

    return GestureDetector(
      onTapDown: (_) => keySize.value = selectedFontSize,
      onTapCancel: () => keySize.value = defaultFontSize,
      onTapUp: (key) {
        keySize.value = defaultFontSize;
        (title == '<') ? onDeletePressed() : onKeyPressed(title);
      },
      child: TextButton(
        onPressed: null,
        style: TextButton.styleFrom(fixedSize: const Size(keyWidth, keyHeight)),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 100),
          style: TextStyle(
            fontSize: keySize.value,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          child: Center(
            child: Text(
              title,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}
