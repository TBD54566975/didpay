import 'package:didpay/shared/theme/color_scheme.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/theme/text_theme.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme(BuildContext context) => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme(ThemeData().textTheme),
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: lightColorScheme.surface,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              return states.contains(WidgetState.selected)
                  ? lightColorScheme.secondary
                  : lightColorScheme.onSecondary;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (_) {
              return BorderSide(
                color: lightColorScheme.secondary,
                width: Grid.quarter,
              );
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Grid.xs),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        alignLabelWithHint: true,
        labelStyle: TextStyle(
          color: lightColorScheme.onSurface,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: Grid.side),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: lightColorScheme.surface,
      ),
      dialogTheme: DialogTheme(
        surfaceTintColor: lightColorScheme.surface,
      ),
    );

ThemeData darkTheme(BuildContext context) => ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: textTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: darkColorScheme.surface,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              return states.contains(WidgetState.selected)
                  ? darkColorScheme.secondary
                  : darkColorScheme.onSecondary;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (_) {
              return BorderSide(
                color: darkColorScheme.secondary,
                width: Grid.quarter,
              );
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Grid.xs),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        alignLabelWithHint: true,
        labelStyle: TextStyle(
          color: darkColorScheme.onSurface,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: Grid.side),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: darkColorScheme.surface,
      ),
      dialogTheme: DialogTheme(
        surfaceTintColor: darkColorScheme.surface,
      ),
    );
