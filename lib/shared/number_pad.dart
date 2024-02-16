import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/shared/theme/grid.dart';

class NumberPad extends HookWidget {
  final ValueNotifier<String> enteredAmount;

  const NumberPad({
    required this.enteredAmount,
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
          enteredAmount: enteredAmount,
        );
      }).toList(),
    );
  }
}

class NumberPadKey extends HookWidget {
  final String title;
  final ValueNotifier<String> enteredAmount;

  const NumberPadKey({
    required this.title,
    required this.enteredAmount,
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
      onTapUp: (_) {
        keySize.value = defaultFontSize;

        title == '<'
            ? _onDeletePressed(enteredAmount)
            : (title == '.' && enteredAmount.value.contains('.'))
                ? null
                : !RegExp(r'\.\d{2}$').hasMatch(enteredAmount.value)
                    ? _onKeyPressed(title, enteredAmount)
                    : null;
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
              title,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }

  void _onDeletePressed(ValueNotifier<String> enteredAmount) {
    enteredAmount.value = (enteredAmount.value.length > 1)
        ? enteredAmount.value.substring(0, enteredAmount.value.length - 1)
        : '0';
  }

  void _onKeyPressed(String title, ValueNotifier<String> enteredAmount) {
    enteredAmount.value = (enteredAmount.value == '0' && title == '.')
        ? '${enteredAmount.value}$title'
        : (enteredAmount.value == '0')
            ? title
            : '${enteredAmount.value}$title';
  }
}
