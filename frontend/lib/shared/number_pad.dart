import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    const defaultSize = 24.0;
    const selectedSize = 40.0;

    final keySize = useState(defaultSize);

    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 100.0,
      height: 50.0,
      child: GestureDetector(
        onTapDown: (_) => keySize.value = selectedSize,
        onTapCancel: () => keySize.value = defaultSize,
        onTapUp: (key) {
          keySize.value = defaultSize;
          (title == '<') ? onDeletePressed() : onKeyPressed(title);
        },
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
