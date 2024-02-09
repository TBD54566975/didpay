import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InvalidNumberPadInputAnimation extends HookWidget {
  final String textValue;
  final bool shouldAnimate;
  final TextStyle? textStyle;

  const InvalidNumberPadInputAnimation(
      {required this.textValue,
      required this.shouldAnimate,
      this.textStyle,
      super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset(0.5 / textValue.length, 0.0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticIn,
    ));

    useEffect(() {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 0), () {
            controller.reverse();
          });
        }
      });
      return;
    }, []);

    useEffect(() {
      if (shouldAnimate) {
        controller.reset();
        controller.forward();
      }
      return null;
    }, [super.hashCode]);

    return SlideTransition(
      position: offsetAnimation,
      child: SizedBox(
        child: Text(
          textValue,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
