import 'package:logger/logger.dart';

var logger = Logger(
  filter: ProductionFilter(),
  printer: SimplePrinter(colors: false),
  output: ConsoleOutput(),
);
