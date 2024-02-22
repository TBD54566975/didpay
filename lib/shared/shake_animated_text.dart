import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShakeAnimatedWidget extends HookWidget {
  final ValueNotifier shouldAnimate;
  final Widget child;

  const ShakeAnimatedWidget({
    required this.shouldAnimate,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 130),
    );

    final animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const _SineCurve(count: 0.6),
      ),
    );

    useEffect(() {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 0), () {
            shouldAnimate.value = false;
            controller.reverse();
          });
        }
      });
      return;
    }, []);

    useEffect(() {
      if (shouldAnimate.value) {
        controller.reset();
        controller.forward();
      }
      return null;
    }, [super.hashCode]);

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(12 * animation.value, 0),
          child: child,
        );
      },
    );
  }
}

class _SineCurve extends Curve {
  final double count;

  const _SineCurve({required this.count});

  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}
