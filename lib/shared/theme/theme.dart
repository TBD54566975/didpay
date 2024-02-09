import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/theme/grid.dart';
import 'package:flutter_starter/shared/theme/color_scheme.dart';
import 'package:flutter_starter/shared/theme/text_theme.dart';

ThemeData lightTheme(BuildContext context) => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme(ThemeData().textTheme),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return states.contains(MaterialState.selected)
                  ? lightColorScheme.surface
                  : lightColorScheme.secondaryContainer;
            },
          ),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> _) {
              return BorderSide(
                color: lightColorScheme.secondaryContainer,
                width: Grid.half,
              );
            },
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Grid.xs)),
          ),
        ),
      ),
    );

ThemeData darkTheme(BuildContext context) => ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: textTheme(ThemeData.dark().textTheme),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return states.contains(MaterialState.selected)
                  ? darkColorScheme.surface
                  : darkColorScheme.secondaryContainer;
            },
          ),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> _) {
              return BorderSide(
                color: darkColorScheme.secondaryContainer,
                width: Grid.half,
              );
            },
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Grid.xs)),
          ),
        ),
      ),
    );
