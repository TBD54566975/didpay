import 'package:flutter/material.dart';

TextTheme textTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge!.copyWith(fontFamily: 'IBMPlexMono'),
    displayMedium: base.displayMedium!.copyWith(fontFamily: 'IBMPlexMono'),
    displaySmall: base.displaySmall!.copyWith(fontFamily: 'IBMPlexMono'),
    headlineLarge: base.headlineLarge!.copyWith(fontFamily: 'IBMPlexMono'),
    headlineMedium: base.headlineMedium!.copyWith(fontFamily: 'IBMPlexMono'),
    headlineSmall: base.headlineSmall!.copyWith(fontFamily: 'IBMPlexMono'),
    titleLarge: base.titleLarge!.copyWith(fontFamily: 'IBMPlexMono'),
    titleMedium: base.titleMedium!.copyWith(fontFamily: 'IBMPlexMono'),
    titleSmall: base.titleSmall!.copyWith(fontFamily: 'IBMPlexMono'),
    bodyLarge: base.bodyLarge!.copyWith(fontFamily: 'IBMPlexMono'),
    bodyMedium: base.bodyMedium!.copyWith(fontFamily: 'IBMPlexMono'),
    bodySmall: base.bodySmall!.copyWith(fontFamily: 'IBMPlexMono'),
    labelLarge: base.labelLarge!.copyWith(fontFamily: 'IBMPlexMono'),
    labelMedium: base.labelMedium!.copyWith(fontFamily: 'IBMPlexMono'),
    labelSmall: base.labelSmall!.copyWith(fontFamily: 'IBMPlexMono'),
  );
}
