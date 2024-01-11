import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NumberPad extends HookWidget {
  final Function(String) onKeyPressed;

  const NumberPad({required this.onKeyPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final pressedKey = useState<String>('');

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return _buildKeyButton(context, key, pressedKey);
      }).toList(),
    );
  }

  Widget _buildKeyButton(
    BuildContext context,
    String key,
    ValueNotifier<String> pressedKey,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Center(
          child: FilledButton(
            onPressed: () {
              _handleKeyPress(pressedKey, key);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
            child: key.isNotEmpty
                ? Text(
                    key,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: pressedKey.value == key ? 34.0 : 20.0,
                        ),
                  )
                : const Spacer(),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(ValueNotifier<String> pressedKey, String key) {
    pressedKey.value = key;
    onKeyPressed(key);

    Future.delayed(const Duration(milliseconds: 100), () {
      pressedKey.value = '';
    });
  }
}
