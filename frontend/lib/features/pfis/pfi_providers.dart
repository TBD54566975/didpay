import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pfisProvider = Provider<List<Pfi>>(
  (ref) => [
    Pfi(id: 'africa', name: 'Africa', widgetUrl: 'https://tbd.website'),
    Pfi(id: 'mexico', name: 'Mexico', widgetUrl: 'https://block.xyz'),
  ],
);
