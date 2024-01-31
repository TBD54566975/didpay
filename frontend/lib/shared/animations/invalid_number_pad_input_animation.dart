import 'package:flutter/material.dart';

class InvalidNumberPadInputAnimation extends StatefulWidget {
  final String textValue;
  final bool shouldAnimate;
  final TextStyle? textStyle;

  const InvalidNumberPadInputAnimation(
      {required this.textValue,
      required this.shouldAnimate,
      this.textStyle,
      super.key});

  @override
  State<InvalidNumberPadInputAnimation> createState() =>
      _InvalidNumberPadInputAnimationState();
}

class _InvalidNumberPadInputAnimationState
    extends State<InvalidNumberPadInputAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: const Offset(0.25, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticIn,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 0), () {
          _controller.reverse();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant InvalidNumberPadInputAnimation prevWidget) {
    super.didUpdateWidget(prevWidget);

    if (widget.shouldAnimate) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: SizedBox(
        child: Text(
          widget.textValue,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
