import 'package:flutter/material.dart';

class SamplePage extends StatelessWidget {
  final String title;
  const SamplePage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
    );
  }
}
