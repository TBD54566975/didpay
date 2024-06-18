import 'package:flutter/material.dart';

class ModalFlow extends StatelessWidget {
  final Widget initialWidget;

  const ModalFlow({required this.initialWidget, super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => initialWidget,
            );
          },
        ),
      );
}
